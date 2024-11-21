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
import TophatUtilities
import AppKit

extension Apps {
	struct Remove: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Removes an application from Quick Launch."
		)

		@Argument(help: "The unique identifier of the entry to remove.")
		var id: String

		func run() throws {
			if !NSRunningApplication.isTophatRunning {
				print("Warning: Tophat must be running for this command to succeed, but it is not running.")
			}

			let notification = TophatRemovePinnedApplicationNotification(payload: .init(id: id))
			TophatInterProcessNotifier().send(notification: notification)
		}
	}
}
