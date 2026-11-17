//
//  GitLabArtifactProviderError.swift
//  Tophat
//
//  Created by Jonathan Seed on 2026-09-23.
//  Copyright © 2026 Shopify. All rights reserved.
//


import Foundation

enum GitLabArtifactProviderError: Error {
    case unauthorized
    case notFound
    case removed
    case unexpected
}

extension GitLabArtifactProviderError: LocalizedError {
    var errorDescription: String? {
        "Failed to Download Artifact"
    }

    var failureReason: String? {
        switch self {
        case .unauthorized:
            "The access token used to authenticate with GitLab is invalid."
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
        case .unauthorized:
            "Go to Tophat Settings → Extensions → GitLab to add or update your token."
        case .notFound, .removed:
            nil
        case .unexpected:
            "Try again later."
        }
    }
}
