//
//  Apps+Remove.swift
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
	struct Remove: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Removes an application from Quick Launch."
		)

		@Argument(help: "The unique identifier of the entry to remove.")
		var id: String

		func run() throws {
			checkIfHostAppIsRunning()

			let request = RemoveQuickLaunchEntryRequest(quickLaunchEntryID: id)
			try TophatRemoteControlService().send(request: request)
		}
	}
}
