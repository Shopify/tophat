//
//  BitriseArtifactProviderError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

enum BitriseArtifactProviderError: Error {
	case accessTokenNotSet
	case unauthorized
	case notFound
	case unexpected
}

extension BitriseArtifactProviderError: LocalizedError {
	var errorDescription: String? {
		"Failed to download artifact"
	}

	var failureReason: String? {
		switch self {
			case .accessTokenNotSet:
				"A Bitrise personal access token has not been specified."
			case .unauthorized:
				"The access token used to authenticate with Bitrise is invalid."
			case .notFound:
				"The requested artifact was not found. It may have expired."
			case .unexpected:
				"An unexpected error has occurred."
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .accessTokenNotSet:
				"Go to Tophat Settings → Extensions → Bitrise to add a token."
			case .unauthorized:
				"Go to Tophat Settings → Extensions → Bitrise to update the token."
			case .notFound:
				nil
			case .unexpected:
				"Try again later."
		}
	}
}
