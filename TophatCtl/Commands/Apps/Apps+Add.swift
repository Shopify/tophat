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
import TophatKit
import AppKit

extension Apps {
	struct Add: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Adds a new application to Quick Launch.",
			discussion: "If an existing item with the same identifier already exists, the item will be updated with new information."
		)

		@Option(help: "The unique identifier of the entry. If not specified, a generated identifier will be used.")
		var id: String?

		@Option(help: "The display name of the application. A short name is best.")
		var name: String

		@Option(help: "The platform of the application.")
		var platform: Platform

		@Option(help: "The URL of the the artifact built for virtual devices.")
		var virtual: URL?

		@Option(help: "The URL of the the artifact built for physical devices.")
		var physical: URL?

		@Option(help: "The URL of the the artifact built for any device type.")
		var universal: URL?

		func run() throws {
			if !NSRunningApplication.isTophatRunning {
				print("Warning: Tophat must be running for this command to succeed, but it is not running.")
			}

			if virtual == nil, physical == nil, universal == nil {
				throw ValidationError("You must specify at least one of --virtual, --physical, or --universal.")
			}

			if universal != nil, virtual != nil || physical != nil {
				throw ValidationError("You must specify one of --universal, or a combination of --virtual and --physical.")
			}

			let payload = TophatAddPinnedApplicationNotification.Payload(
				id: id,
				name: name,
				platform: platform,
				virtualURL: virtual,
				physicalURL: physical,
				universalURL: universal
			)

			let notification = TophatAddPinnedApplicationNotification(payload: payload)
			TophatInterProcessNotifier().send(notification: notification)
		}
	}
}
