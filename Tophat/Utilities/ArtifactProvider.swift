//
//  ArtifactProvider.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-03-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

final class ArtifactProvider {
	private let url: URL

	init(url: URL) {
		self.url = url
	}

	func fetchArtifacts() async throws -> ArtifactProviderResponse {
		log.info("Requesting artifacts from \(url.absoluteString)")
		let (data, response) = try await makeAuthenticatedRequest(to: url)

		guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
			throw ArtifactProviderError.unauthorized
		}

		let decodedResponse = try JSONDecoder().decode(ArtifactProviderResponse.self, from: data)
		return decodedResponse
	}

	private func makeAuthenticatedRequest(to url: URL) async throws -> (Data, URLResponse) {
		let token = try readToken()
		let credentials = String(format: "%@:%@", "TOPHAT_APP_TOKEN", token)

		guard let credentialsData = credentials.data(using: .utf8) else {
			throw ArtifactProviderError.invalidCredentials
		}

		let encodedCredentials = credentialsData.base64EncodedString()

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		return try await URLSession.shared.data(for: request)
	}

	private func readToken() throws -> String {
		guard let token = try? String(contentsOf: .homeDirectory.appending(path: ".tophatrc")), !token.isEmpty else {
			throw ArtifactProviderError.missingToken
		}

		return token
	}
}

enum ArtifactProviderError: Error {
	case missingToken
	case invalidCredentials
	case unauthorized
}
