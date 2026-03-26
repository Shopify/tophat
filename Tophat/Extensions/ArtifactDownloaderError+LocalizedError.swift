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
			case .untrustedHost:
				"The download was aborted."
		}
	}

	var failureReason: String? {
		switch self {
			case .untrustedHost:
				"The build is hosted on a server that hasn’t been trusted."
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .untrustedHost:
				"Verify that you trust the source before trying again."
		}
	}
}
