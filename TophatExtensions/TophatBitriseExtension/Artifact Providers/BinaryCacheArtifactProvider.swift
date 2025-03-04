//
//  BinaryCacheArtifactProvider.swift
//  Tophat
//
//  Created by Yasmin Benatti on 2025-03-04.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation
import TophatKit

struct BinaryCacheArtifactProvider: ArtifactProvider {
	@SecureStorage(Constants.keychainPersonalAccessTokenKey) var personalAccessToken: String?

	static let id = "bitrise-binary-cache"
	static let title: LocalizedStringResource = "Bitrise (Binary Cache)"

	private let baseURL = URL(string: "https://api.bitrise.io/v0.1")!

	@Parameter(key: "app_slug", title: "App Slug")
	var appSlug: String

	@Parameter(key: "platform", title: "Platform")
	var platform: String

	@Parameter(key: "variant", title: "Variant")
	var variant: String

	@Parameter(key: "cache_name", title: "Cache name")
	var cache_name: String

	@Parameter(key: "cache_key", title: "Cache key")
	var cache_key: String

	private var cacheItemsURL: URL {
		baseURL
			.appending(path: "apps")
			.appending(path: appSlug)
			.appending(path: "cache-items")
	}

	func retrieve() async throws -> some ArtifactProviderResult {
		guard let personalAccessToken, !personalAccessToken.isEmpty else {
			throw BitriseArtifactProviderError.accessTokenNotSet
		}

		// Fetch cache items for app.

		let cacheItemsRequest = makeAuthenticatedRequest(url: cacheItemsURL)
		let (cacheItemsResponseData, cacheItemsResponse) = try await URLSession.shared.data(for: cacheItemsRequest)
		try validateBitriseResponse(response: cacheItemsResponse)
		let cacheItemsListResponse = try JSONDecoder().decode(CacheItemListResponseModel.self, from: cacheItemsResponseData)

		guard let cacheItemsListData = cacheItemsListResponse.data else {
			throw BinaryCacheArtifactProviderError.noCacheFound
		}

		// Search for cache key on the first page

		if let cacheItem = cacheItemsListData.first { $0["cache_key"] as? String == cacheKey } as CacheItemResponseModel {
			return cacheItem.cache_key
		}

		// Check if there's a next page

		if let paging = cacheItemsListResponse["paging"] as? [String: Any], let next = paging["next"] as? String {
			nextPage = next
			// call method again
		}
	}

	func cleanUp(localURL: URL) async throws {
		try FileManager.default.removeItem(at: localURL)
	}

	private func makeAuthenticatedRequest(url: URL) -> URLRequest {
		var request = URLRequest(url: url)
		request.setValue(personalAccessToken, forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		return request
	}
}

enum BinaryCacheArtifactProviderError: Error {
	case noCacheFound
}

extension BinaryCacheArtifactProviderError: LocalizedError {
	var errorDescription: String? {
		"Failed to download cache"
	}

	var failureReason: String? {
		switch self {
			case .noCacheFound:
				"No cache for the specified app and cache key were found on Bitrise."
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .noCacheFound:
				"Check app and cache key and try again."
		}
	}
}
