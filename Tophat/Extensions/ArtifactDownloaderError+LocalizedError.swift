//
//  ArtifactDownloaderError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-04-14.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

extension ArtifactDownloaderError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .failedToDownloadArtifact:
				return "The artifact could not be downloaded"
			default:
				return nil
		}
	}

	var failureReason: String? {
		switch self {
			case .failedToDownloadArtifact:
				return "An unexpected error occurred while downloading the artifact."
			default:
				return nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .failedToDownloadArtifact:
				return "Check your network connection and try again."
			default:
				return nil
		}
	}
}
