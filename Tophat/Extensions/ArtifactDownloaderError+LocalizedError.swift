//
//  ArtifactDownloaderError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

extension ArtifactDownloaderError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .failedToDownloadArtifact:
				return "The artifact could not be downloaded"
		}
	}

	var failureReason: String? {
		switch self {
			case .failedToDownloadArtifact:
				return "An unexpected error occurred while downloading the artifact."
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .failedToDownloadArtifact:
				return "Check your network connection and try again."
		}
	}
}
