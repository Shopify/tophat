//
//  GitHubActionsArtifactProviderError.swift
//  TophatGitHubActionsExtension
//
//  Created by Doan Thieu on 24/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation

enum GitHubActionsArtifactProviderError: Error {
	case accessTokenNotSet
	case unauthorized
	case notFound
	case removed
	case unexpected
}

extension GitHubActionsArtifactProviderError: LocalizedError {
	var errorDescription: String? {
		"Failed to Download Artifact"
	}

	var failureReason: String? {
		switch self {
		case .accessTokenNotSet:
			"A GitHub personal access token is required."
		case .unauthorized:
			"The access token used to authenticate with GitHub is invalid."
		case .notFound:
			"The requested artifact was not found. It may have expired."
		case .removed:
			"The requested artifact was permanently removed."
		case .unexpected:
			"Something went wrong that Tophat wasn’t able to identify."
		}
	}

	var recoverySuggestion: String? {
		switch self {
		case .accessTokenNotSet:
			"Go to Tophat Settings → Extensions → GitHub Actions to add a token."
		case .unauthorized:
			"Go to Tophat Settings → Extensions → GitHub Actions to update the token."
		case .notFound, .removed:
			nil
		case .unexpected:
			"Try again later."
		}
	}
}
