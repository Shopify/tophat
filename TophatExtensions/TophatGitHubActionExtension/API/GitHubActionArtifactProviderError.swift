//
//  GitHubActionArtifactProviderError.swift
//  TophatGitHubActionExtension
//
//  Created by Doan Thieu on 24/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation

enum GitHubActionArtifactProviderError: Error {
    case accessTokenNotSet
    case unauthorized
    case notFound
    case removed
    case unexpected
}

extension GitHubActionArtifactProviderError: LocalizedError {
    var errorDescription: String? {
        "Failed to download artifact"
    }

    var failureReason: String? {
        switch self {
        case .accessTokenNotSet:
            "A GitHub personal access token has not been specified."
        case .unauthorized:
            "The access token used to authenticate with GitHub is invalid."
        case .notFound:
            "The requested artifact was not found. It may have expired."
        case .removed:
            "The requested artifact was permanently removed."
        case .unexpected:
            "An unexpected error has occurred."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .accessTokenNotSet:
            "Go to Tophat Settings → Extensions → GitHub Action to add a token."
        case .unauthorized:
            "Go to Tophat Settings → Extensions → GitHub Action to update the token."
        case .notFound, .removed:
            nil
        case .unexpected:
            "Try again later."
        }
    }
}
