//
//  GitHubActionsArtifactProvider.swift
//  TophatGitHubActionsExtension
//
//  Created by Doan Thieu on 23/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation
import SecureStorage
import TophatKit

struct GitHubActionsArtifactProvider: ArtifactProvider {

    @SecureStorage(Constants.keychainGitHubPersonalAccessTokenKey)
    var personalAccessToken: String?

    static let id = "gha"
    static let title: LocalizedStringResource = "GitHub Actions"

    @Parameter(key: "owner", title: "Owner")
    var owner: String

    @Parameter(key: "repo", title: "Repository")
    var repository: String

    @Parameter(key: "artifact_id", title: "Artifact ID")
    var artifactId: String

    private let fileManager = FileManager.default

    func retrieve() async throws -> any ArtifactProviderResult {
        guard let personalAccessToken, !personalAccessToken.isEmpty else {
            throw GitHubActionsArtifactProviderError.accessTokenNotSet
        }

        let apiClient = GitHubActionsAPIClient(personalAccessToken: personalAccessToken)
        let (downloadedFileURL, urlResponse) = try await apiClient.downloadArtifact(
            owner: owner,
            repository: repository,
            artifactId: artifactId
        )

        try validateResponse(urlResponse)
        let destinationDirectoryURL: URL = .temporaryDirectory.appending(path: UUID().uuidString)
        try fileManager.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)

        let destinationURL = destinationDirectoryURL
            .appending(component: urlResponse.suggestedFilename ?? downloadedFileURL.lastPathComponent)

        try fileManager.moveItem(at: downloadedFileURL, to: destinationURL)
        return .result(localURL: destinationURL)
    }

    func cleanUp(localURL: URL) async throws {
        try fileManager.removeItem(at: localURL)
    }
}

extension GitHubActionsArtifactProvider {

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubActionsArtifactProviderError.unexpected
        }

        guard httpResponse.statusCode == 302 else {
            switch httpResponse.statusCode {
            case 401:
                throw GitHubActionsArtifactProviderError.unauthorized
            case 404:
                throw GitHubActionsArtifactProviderError.notFound
            case 410:
                throw GitHubActionsArtifactProviderError.removed
            default:
                throw GitHubActionsArtifactProviderError.unexpected
            }
        }
    }
}
