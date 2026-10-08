//
//  GitLabArtifactProvider.swift
//  Tophat
//
//  Created by Jonathan Seed on 2026-09-23.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import TophatKit

struct GitLabArtifactProvider: ArtifactProvider {

    @SecureStorage(Constants.keychainGitLabPersonalAccessTokenKey)
    var personalAccessToken: String?

    static let id = "glab"
    static let title: LocalizedStringResource = "GitLab"

    @Parameter(key: "project_id", title: "Project ID")
    var projectId: String

    @Parameter(key: "job_id", title: "Job ID")
    var jobId: String

    @Parameter(key: "artifact_path", title: "Artifact Path")
    var artifactPath: String

    private let fileManager = FileManager.default

    func retrieve() async throws -> any ArtifactProviderResult {
        let apiClient = GitLabAPIClient(personalAccessToken: personalAccessToken)
        let (downloadedFileURL, urlResponse) = try await apiClient.downloadArtifact(
            projectId: projectId,
            jobId: jobId,
            artifactPath: artifactPath
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

extension GitLabArtifactProvider {

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitLabArtifactProviderError.unexpected
        }

        guard httpResponse.statusCode == 200 else {
            switch httpResponse.statusCode {
            case 401:
                throw GitLabArtifactProviderError.unauthorized
            case 404:
                throw GitLabArtifactProviderError.notFound
            case 410:
                throw GitLabArtifactProviderError.removed
            default:
                throw GitLabArtifactProviderError.unexpected
            }
        }
    }
}
