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
import TophatControlServices
import AppKit

extension Apps {
	struct Add: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Adds a new application to Quick Launch.",
			discussion: "If an existing item with the same identifier already exists, the item will be updated with new information."
		)

		@Argument(help: "The path to the configuration file for the app.")
		var path: URL

		func run() async throws {
			checkIfHostAppIsRunning()

			let data = try Data(contentsOf: path)
			let configuration = try JSONDecoder().decode(UserSpecifiedQuickLaunchEntryConfiguration.self, from: data)

			let request = AddQuickLaunchEntryRequest(configuration: configuration)
			try TophatRemoteControlService().send(request: request)
		}
	}
}
