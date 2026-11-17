//
//  GitLabAPIClient.swift
//  Tophat
//
//  Created by Jonathan Seed on 2026-09-23.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

struct GitLabAPIClient {

    private let personalAccessToken: String?
    private let baseAPIUrl = "https://gitlab.com/api/v4"

    init(personalAccessToken: String?) {
        self.personalAccessToken = personalAccessToken
    }

    private var urlSession = URLSession.shared

    func downloadArtifact(
        projectId: String,
        jobId: String,
        artifactPath: String
    ) async throws -> (URL, URLResponse) {
        let url = URL(string: baseAPIUrl)!
            .appending(path: "projects")
            .appending(path: projectId)
            .appending(path: "jobs")
            .appending(path: jobId)
            .appending(path: "artifacts")
            .appending(path: artifactPath)

        let urlRequest = makeURLRequest(url: url, token: personalAccessToken)

        return try await urlSession.download(for: urlRequest)
    }
}

extension GitLabAPIClient {

    private func makeURLRequest(url: URL, token: String?) -> URLRequest {
        var request = URLRequest(url: url)

        var headers: [String: String] = [:]

        if let token, !token.isEmpty {
            headers["PRIVATE-TOKEN"] = "\(token)"
        }

        headers.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }
}
