//
//  GitHubActionArtifactProvider.swift
//  TophatGitHubActionExtension
//
//  Created by Doan Thieu on 23/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation
import SecureStorage
import TophatKit

struct GitHubActionArtifactProvider: ArtifactProvider {

    struct Error: Swift.Error {}

    @SecureStorage(Constants.keychainGitHubPersonalAccessTokenKey)
    var personalAccessToken: String?

    static let id = "gha"
    static let title: LocalizedStringResource = "GitHub Action"

    @Parameter(key: "owner", title: "Owner")
    var owner: String

    @Parameter(key: "repo", title: "Repository")
    var repository: String

    @Parameter(key: "artifact_id", title: "Artifact Id")
    var artifactId: String

    private var apiClient: GitHubActionAPIClient? {
        personalAccessToken.map(GitHubActionAPIClient.init)
    }

    private var urlSession = URLSession.shared
    private let fileManager = FileManager.default

    func retrieve() async throws -> any ArtifactProviderResult {
        guard let apiClient else {
            throw Error()
        }

        let (downloadedFileURL, suggestedFilename) = try await apiClient.downloadArtifact(
            owner: owner,
            repository: repository,
            artifactId: artifactId
        )

        let destinationDirectoryURL: URL = .temporaryDirectory.appending(path: UUID().uuidString)
        try fileManager.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)

        let destinationURL = destinationDirectoryURL
            .appending(component: suggestedFilename ?? downloadedFileURL.lastPathComponent)

        try fileManager.moveItem(at: downloadedFileURL, to: destinationURL)

        return .result(localURL: destinationURL)
    }

    func cleanUp(localURL: URL) async throws {
        try fileManager.removeItem(at: localURL)
    }
}
