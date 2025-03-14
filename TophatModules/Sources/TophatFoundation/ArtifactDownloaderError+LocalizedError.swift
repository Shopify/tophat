//
//  ArtifactDownloaderError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

extension ArtifactDownloaderError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case .failedToDownloadArtifact(let reason):
				"The artifact could not be downloaded: \(reason)"
			case .untrustedHost:
				"The download was aborted"
		}
	}

	public var failureReason: String? {
		switch self {
			case .failedToDownloadArtifact:
				"An unexpected error occurred while downloading the artifact."
			case .untrustedHost:
				"The host that the artifact is being downloaded from is untrusted."
		}
	}

	public var recoverySuggestion: String? {
		switch self {
			case .failedToDownloadArtifact:
				"Check your network connection and try again."
			case .untrustedHost:
				"Verify that you trust the origin of the artifact before retrying."
		}
	}
}
