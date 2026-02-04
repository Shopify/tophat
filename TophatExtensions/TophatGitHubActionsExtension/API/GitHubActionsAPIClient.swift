//
//  GitHubActionsAPIClient.swift
//  TophatGitHubActionsExtension
//
//  Created by Doan Thieu on 23/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation

struct GitHubActionsAPIClient {

    private let personalAccessToken: String
    private let baseAPIUrl = "https://api.github.com"
    private let apiVersion = "2022-11-28"
    private let archiveFormat = "zip"

    init(personalAccessToken: String) {
        self.personalAccessToken = personalAccessToken
    }

    private var urlSession = URLSession.shared

    func downloadArtifact(
        owner: String,
        repository: String,
        artifactId: String
    ) async throws -> (URL, URLResponse) {
        let url = URL(string: baseAPIUrl)!
            .appending(path: "repos")
            .appending(path: owner)
            .appending(path: repository)
            .appending(path: "actions")
            .appending(path: "artifacts")
            .appending(path: artifactId)
            .appending(path: archiveFormat)

        let urlRequest = makeURLRequest(url: url, apiVersion: apiVersion, token: personalAccessToken)

        return try await urlSession.download(for: urlRequest)
    }
}

extension GitHubActionsAPIClient {

    private func makeURLRequest(url: URL, apiVersion: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)

        let headers: [String: String] = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": apiVersion
        ]

        headers.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }
}
