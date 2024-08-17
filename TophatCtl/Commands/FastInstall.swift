//
//  FastInstall.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-26.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ArgumentParser
import TophatFoundation
import TophatKit

struct FastInstall: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "fast-install",
		abstract: "Installs an application, preparing the required device in advance.",
		discussion: "This command uses platform and build type hints to prepare the device earlier to speed up the installation process."
	)

	@Argument(help: "The platform to install the artifact on.")
	var platform: Platform

	@Option(name: [.short, .long], help: "The URL or path of the artifact built for virtual devices.")
	var virtual: URL?

	@Option(name: [.short, .long], help: "The URL or path of the artifact built for physical devices.")
	var physical: URL?

	@Option(name: [.short, .long], help: "The URL or path of the artifact built for any device type.")
	var universal: URL?

	@Option(parsing: .upToNextOption, help: "Arguments to pass to the application on launch.")
	var launchArguments: [String] = []

	func run() throws {
		if virtual == nil, physical == nil, universal == nil {
			throw ValidationError("You must specify at least one of --virtual, --physical, or --universal.")
		}

		if universal != nil, virtual != nil || physical != nil {
			throw ValidationError("You must specify either --universal, or a combination of --virtual and --physical.")
		}

		let payload = TophatInstallHintedNotification.Payload(
			platform: platform,
			virtualURL: virtual,
			physicalURL: physical,
			universalURL: universal,
			launchArguments: launchArguments
		)

		let notification = TophatInstallHintedNotification(payload: payload)
		TophatInterProcessNotifier().send(notification: notification)
	}
}
