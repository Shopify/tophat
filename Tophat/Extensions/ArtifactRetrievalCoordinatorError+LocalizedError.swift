//
//  ArtifactRetrievalCoordinatorError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

extension ArtifactRetrievalCoordinatorError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .artifactProviderNotFound(let id) where id == "ios" || id == "android":
				"This link is not compatible with Tophat 2"
			case .artifactProviderNotFound:
				"The artifact could not be downloaded"
		}
	}

	var failureReason: String? {
		switch self {
			case .artifactProviderNotFound(let id) where id == "ios" || id == "android":
				"The link you opened is only compatible with Tophat 1, but you are using a newer version of Tophat."
			case .artifactProviderNotFound(let id):
				"An artifact provider with identifier \(id) could not be found."
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .artifactProviderNotFound(let id) where id == "ios" || id == "android":
				"Update the link format or install Tophat 1 to continue using the legacy format."
			case .artifactProviderNotFound:
				"Make sure you entered the correct identifier and try again."
		}
	}
}
