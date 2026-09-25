//
//  XcodeCloudArtifactProvider.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import TophatKit

struct XcodeCloudArtifactProvider: ArtifactProvider {
	@SecureStorage(Constants.keychainIssuerIDKey) var issuerID: String?
	@SecureStorage(Constants.keychainKeyIDKey) var keyID: String?
	@SecureStorage(Constants.keychainPrivateKeyKey) var privateKey: String?

	static let id = "xcode-cloud"
	static let title: LocalizedStringResource = "Xcode Cloud"

	private let baseURL = URL(string: "https://api.appstoreconnect.apple.com/v1")!

	@Parameter(
		key: "build_run_id",
		title: "Build Run ID",
		description: "The identifier of the Xcode Cloud build, available as CI_BUILD_ID in a custom build script.",
		prompt: "Build Run ID"
	)
	var buildRunID: String

	@Parameter(
		key: "artifact",
		title: "Artifact",
		description: "Use “build-products” to install on a simulator, or the name of an export such as “development” or “ad-hoc” to install on a device.",
		prompt: "Artifact Name"
	)
	var artifact: String

	private var buildActionsURL: URL {
		baseURL
			.appending(path: "ciBuildRuns")
			.appending(path: buildRunID)
			.appending(path: "actions")
	}

	func retrieve() async throws -> some ArtifactProviderResult {
		guard
			let issuerID, !issuerID.isEmpty,
			let keyID, !keyID.isEmpty,
			let privateKey, !privateKey.isEmpty
		else {
			throw XcodeCloudArtifactProviderError.credentialsNotSet
		}

		let token = try AppStoreConnectJWT(issuerID: issuerID, keyID: keyID, privateKey: privateKey).makeToken()

		// Fetch actions for build.

		let buildActionsRequest = makeAuthenticatedURLRequest(url: buildActionsURL, token: token)
		let (buildActionsResponseData, buildActionsResponse) = try await URLSession.shared.data(for: buildActionsRequest)
		try validateResponse(buildActionsResponse)
		let buildActionsListResponse = try JSONDecoder().decode(CiBuildActionListResponseModel.self, from: buildActionsResponseData)

		// Fetch artifacts for each action until a match is found. A workflow can define
		// more than one action, and each produces its own artifacts, so the one being
		// asked for may belong to any of them.

		var matchingArtifact: CiArtifactResponseItemModel?

		for buildAction in buildActionsListResponse.data {
			let artifactsURL = baseURL
				.appending(path: "ciBuildActions")
				.appending(path: buildAction.id)
				.appending(path: "artifacts")

			let artifactsRequest = makeAuthenticatedURLRequest(url: artifactsURL, token: token)
			let (artifactsResponseData, artifactsResponse) = try await URLSession.shared.data(for: artifactsRequest)
			try validateResponse(artifactsResponse)
			let artifactsListResponse = try JSONDecoder().decode(CiArtifactListResponseModel.self, from: artifactsResponseData)

			if let match = artifactsListResponse.data.first(where: matches(artifact:)) {
				matchingArtifact = match
				break
			}
		}

		guard let matchingArtifact else {
			throw XcodeCloudArtifactProviderError.artifactNotFound
		}

		guard let downloadURL = matchingArtifact.attributes?.downloadURL else {
			throw XcodeCloudArtifactProviderError.artifactNotReady
		}

		// Download artifact. The URL is pre-signed, so no authorization header is needed.

		let (downloadedFileURL, downloadResponse) = try await URLSession.shared.download(from: downloadURL)
		try validateDownloadResponse(downloadResponse)

		let destinationDirectoryURL: URL = .temporaryDirectory.appending(path: UUID().uuidString)
		try FileManager.default.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)

		// Tophat determines how to unpack an artifact from its path extension, so the name
		// reported by App Store Connect is preferred over the one suggested by the download.
		let fileName = matchingArtifact.attributes?.fileName
			?? downloadResponse.suggestedFilename
			?? downloadedFileURL.lastPathComponent

		let destinationURL = destinationDirectoryURL.appending(component: fileName)
		try FileManager.default.moveItem(at: downloadedFileURL, to: destinationURL)

		return .result(localURL: destinationURL)
	}

	func cleanUp(localURL: URL) async throws {
		try FileManager.default.removeItem(at: localURL)
	}
}

private extension XcodeCloudArtifactProvider {
	/// The value of the artifact parameter that selects the products of a build action rather
	/// than an export of an archive.
	static let buildProductsArtifact = "build-products"

	func makeAuthenticatedURLRequest(url: URL, token: String) -> URLRequest {
		var request = URLRequest(url: url)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		return request
	}

	/// Determines whether an artifact is the one that the artifact parameter selects.
	///
	/// Xcode Cloud names an export after the method that produced it, such as
	/// `MyApp 1.0.2 development.zip`, so the trailing component of the name identifies the
	/// export and stays stable across builds.
	func matches(artifact candidate: CiArtifactResponseItemModel) -> Bool {
		guard let attributes = candidate.attributes else {
			return false
		}

		if artifact == Self.buildProductsArtifact {
			return attributes.fileType == CiArtifactResponseItemModel.buildProductsFileType
		}

		guard
			attributes.fileType == CiArtifactResponseItemModel.archiveExportFileType,
			let fileName = attributes.fileName,
			let exportMethod = URL(fileURLWithPath: fileName)
				.deletingPathExtension()
				.lastPathComponent
				.split(separator: " ")
				.last
		else {
			return false
		}

		return String(exportMethod) == artifact
	}

	func validateResponse(_ response: URLResponse) throws {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw XcodeCloudArtifactProviderError.unexpected
		}

		guard httpResponse.statusCode == 200 else {
			switch httpResponse.statusCode {
				case 401:
					throw XcodeCloudArtifactProviderError.unauthorized
				case 403:
					throw XcodeCloudArtifactProviderError.forbidden
				case 404:
					throw XcodeCloudArtifactProviderError.buildRunNotFound
				default:
					throw XcodeCloudArtifactProviderError.unexpected
			}
		}
	}

	/// Validates a response from the pre-signed download URL. A rejection here means the
	/// artifact can no longer be retrieved rather than that the build could not be found.
	func validateDownloadResponse(_ response: URLResponse) throws {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw XcodeCloudArtifactProviderError.unexpected
		}

		guard httpResponse.statusCode == 200 else {
			switch httpResponse.statusCode {
				case 403, 404, 410:
					throw XcodeCloudArtifactProviderError.artifactExpired
				default:
					throw XcodeCloudArtifactProviderError.unexpected
			}
		}
	}
}
