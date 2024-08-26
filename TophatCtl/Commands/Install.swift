//
//  Install.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-26.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ArgumentParser
import TophatFoundation
import TophatKit

struct Install: ParsableCommand {
	static var configuration = CommandConfiguration(
		abstract: "Installs an application.",
		discussion: "This command infers platform and build type after the artifact has been downloaded. It is ideal for local artifacts that don't take any time to download."
	)

	@Argument(help: "The URL or local path of the artifact.")
	var url: URL

	@Option(parsing: .upToNextOption, help: "Arguments to pass to the application on launch.")
	var launchArguments: [String] = []

	func run() throws {
		let payload = TophatInstallGenericNotification.Payload(
			url: url,
			launchArguments: launchArguments
		)

		let notification = TophatInstallGenericNotification(payload: payload)
		TophatInterProcessNotifier().send(notification: notification)
	}
}
