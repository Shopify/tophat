//
//  BasicArtifactProvider.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatKit

struct BasicArtifactProvider: ArtifactProvider {
	@SecureStorage(Constants.keychainPersonalAccessTokenKey) var personalAccessToken: String?

	static let id = "bitrise"
	static let title: LocalizedStringResource = "Bitrise"

	@Parameter(key: "app_slug", title: "App Slug")
	var appSlug: String

	@Parameter(key: "build_slug", title: "Build Slug")
	var buildSlug: String

	@Parameter(key: "artifact_slug", title: "Artifact Slug")
	var artifactSlug: String

	private var url: URL {
		URL(string: "https://api.bitrise.io/v0.1")!
			.appending(path: "apps")
			.appending(path: appSlug)
			.appending(path: "builds")
			.appending(path: buildSlug)
			.appending(path: "artifacts")
			.appending(path: artifactSlug)
	}

	func retrieve() async throws -> some ArtifactProviderResult {
		guard let personalAccessToken, !personalAccessToken.isEmpty else {
			throw BitriseArtifactProviderError.accessTokenNotSet
		}

		// Fetch artifact details.

		let artifactRequest = makeAuthenticatedURLRequest(url: url, token: personalAccessToken)
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
}
