//
//  ArtifactProvider+ValidateBitriseResponse.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatKit

extension ArtifactProvider {
	func makeAuthenticatedURLRequest(url: URL, token: String) -> URLRequest {
		var request = URLRequest(url: url)
		request.setValue(token, forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		return request
	}

	func validateBitriseResponse(response: URLResponse) throws {
		guard let artifactHTTPResponse = response as? HTTPURLResponse else {
			throw BitriseArtifactProviderError.unexpected
		}

		guard artifactHTTPResponse.statusCode == 200 else {
			switch artifactHTTPResponse.statusCode {
				case 401:
					throw BitriseArtifactProviderError.unauthorized
				case 404:
					throw BitriseArtifactProviderError.notFound
				default:
					throw BitriseArtifactProviderError.unexpected
			}
		}
	}
}
