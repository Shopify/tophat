//
//  QuickLaunchEntryNotFoundError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2026-03-09.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

struct QuickLaunchEntryNotFoundError: LocalizedError {
	let identifier: String

	var errorDescription: String? {
		"App Not Found"
	}

	var failureReason: String? {
		"No app with identifier \"\(identifier)\" exists."
	}

	var recoverySuggestion: String? {
		"Verify the identifier and try again."
	}
}
