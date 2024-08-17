//
//  Bundle+Extensions.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-31.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

extension Bundle {
	var displayName: String? {
		object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
	}

	var shortVersionString: String? {
		infoDictionary?["CFBundleShortVersionString"] as? String
	}

	var buildNumber: String? {
		infoDictionary?["CFBundleVersion"] as? String
	}

	var humanReadableCopyright: String? {
		infoDictionary?["NSHumanReadableCopyright"] as? String
	}
}
