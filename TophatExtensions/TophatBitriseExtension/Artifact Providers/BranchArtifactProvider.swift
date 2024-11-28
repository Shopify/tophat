//
//  BranchArtifactProvider.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatKit

struct BranchArtifactProvider: ArtifactProvider {
	@SecureStorage(Constants.keychainPersonalAccessTokenKey) var personalAccessToken: String?

	static let id = "bitrise-branch"
	static let title: LocalizedStringResource = "Bitrise (Branch)"

	private let baseURL = URL(string: "https://api.bitrise.io/v0.1")!

	@Parameter(key: "app_slug", title: "App Slug")
	var appSlug: String

	@Parameter(key: "branch", title: "Branch")
	var branch: String

	@Parameter(key: "workflow", title: "Workflow Name")
	var workflow: String

	@Parameter(key: "artifact_name", title: "Artifact Name")
	var artifactName: String

	private var buildsURL: URL {
		baseURL
			.appending(path: "apps")
			.appending(path: appSlug)
			.appending(path: "builds")
	}

	func retrieve() async throws -> some ArtifactProviderResult {
		guard let personalAccessToken, !personalAccessToken.isEmpty else {
			throw BitriseArtifactProviderError.accessTokenNotSet
		}

		// Fetch builds for branch.

		let buildsRequestURL = buildsURL.appending(
			queryItems: [
				.init(name: "branch", value: branch),
				.init(name: "workflow", value: workflow),
				.init(name: "status", value: "1"),
				.init(name: "limit", value: "1")
			]
		)

		let buildsRequest = makeAuthenticatedRequest(url: buildsRequestURL)
		let (buildsResponseData, buildsResponse) = try await URLSession.shared.data(for: buildsRequest)
		try validateBitriseResponse(response: buildsResponse)
		let buildsListResponse = try JSONDecoder().decode(BuildListResponseModel.self, from: buildsResponseData)

		guard let latestBuild = buildsListResponse.data.first else {
			throw BranchArtifactProviderError.noBuildsFound
		}

		// Fetch artifacts for build.

		let artifactsURL = buildsURL.appending(path: latestBuild.slug).appending(path: "artifacts")

		let artifactsRequest = makeAuthenticatedRequest(url: artifactsURL)
		let (artifactsResponseData, artifactsResponse) = try await URLSession.shared.data(for: artifactsRequest)
		try validateBitriseResponse(response: artifactsResponse)
		let artifactsListResponse = try JSONDecoder().decode(ArtifactListResponseModel.self, from: artifactsResponseData)

		guard let matchingArtifact = artifactsListResponse.data.first(where: { $0.title == artifactName }) else {
			throw BranchArtifactProviderError.artifactNotFound
		}

		// Fetch artifact details.

		let artifactRequest = makeAuthenticatedRequest(url: artifactsURL.appending(path: matchingArtifact.slug))
		let (artifactResponseData, artifactResponse) = try await URLSession.shared.data(for: artifactRequest)
		try validateBitriseResponse(response: artifactResponse)
		let artifactShowResponse = try JSONDecoder().decode(ArtifactShowResponseModel.self, from: artifactResponseData)

		// Download artifact.

		let destinationDirectoryURL: URL = .temporaryDirectory.appending(path: UUID().uuidString)
		try FileManager.default.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)

		let (downloadedFileURL, nextResponse) = try await URLSession.shared.download(
			from: artifactShowResponse.data.expiringDownloadURL
		)

		let destinationURL = destinationDirectoryURL
			.appending(component: nextResponse.suggestedFilename ?? downloadedFileURL.lastPathComponent)

		try FileManager.default.moveItem(at: downloadedFileURL, to: destinationURL)

		return .result(localURL: destinationURL)
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

enum BranchArtifactProviderError: Error {
	case noBuildsFound
	case artifactNotFound
}

extension BranchArtifactProviderError: LocalizedError {
	var errorDescription: String? {
		"Failed to download artifact"
	}

	var failureReason: String? {
		switch self {
			case .noBuildsFound:
				"No builds for the specified branch and workflow were found on Bitrise."
			case .artifactNotFound:
				"No matching artifact was found for the specified branch and workflow on Bitrise."
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .noBuildsFound:
				"Check branch and workflow names and try again."
			case .artifactNotFound:
				"Check the artifact name and try again."
		}
	}
}
