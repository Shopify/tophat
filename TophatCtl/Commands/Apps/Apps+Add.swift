//
//  Apps+Add.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ArgumentParser
import TophatFoundation
import TophatUtilities
import AppKit

extension Apps {
	struct Add: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Adds a new application to Quick Launch.",
			discussion: "If an existing item with the same identifier already exists, the item will be updated with new information."
		)

		@Argument(help: "The path to the configuration file for the app.")
		var path: URL

		func run() throws {
			if !NSRunningApplication.isTophatRunning {
				print("Warning: Tophat must be running for this command to succeed, but it is not running.")
			}

			let data = try Data(contentsOf: path)
			let configuration = try JSONDecoder().decode(UserSpecifiedQuickLaunchEntryConfiguration.self, from: data)

			let payload = TophatAddQuickLaunchEntryNotification.Payload(
				configuration: configuration
			)

			let notification = TophatAddQuickLaunchEntryNotification(payload: payload)
			TophatInterProcessNotifier().send(notification: notification)
		}
	}
}
