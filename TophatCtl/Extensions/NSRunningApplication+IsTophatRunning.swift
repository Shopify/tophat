//
//  NSRunningApplication+IsTophatRunning.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit

extension NSRunningApplication {
	static var isTophatRunning: Bool {
		!runningApplications(withBundleIdentifier: "com.shopify.Tophat").isEmpty
	}
}
