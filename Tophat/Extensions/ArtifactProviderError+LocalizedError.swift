//
//  ArtifactProviderError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-03-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

extension ArtifactProviderError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .missingToken, .unauthorized:
				return "Failed to download application"
			default:
				return nil
		}
	}

	var failureReason: String? {
		switch self {
			case .missingToken:
				return "A token is required to authenticate but none was found."
			case .unauthorized:
				return "The token used to authenticate is invalid."
			default:
				return nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .missingToken:
				return "Place the correct token in ~/.tophatrc and try again."
			case .unauthorized:
				return "Ensure the token in ~/.tophatrc is up to date and try again."
			default:
				return nil
		}
	}
}
