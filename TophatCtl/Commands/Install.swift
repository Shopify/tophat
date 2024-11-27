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
import TophatUtilities

struct Install: ParsableCommand {
	static var configuration = CommandConfiguration(
		abstract: "Installs an application.",
		discussion: "This command infers platform and build type after the artifact has been downloaded. It is ideal for local artifacts that don't take any time to download."
	)

	@Option(name: [.short, .long], help: "The URL or local path of the artifact.")
	var url: URL? = nil

	@Option(name: [.short, .long], help: "The path to the configuration file to use for installation.")
	var configuration: URL? = nil

	@Option(parsing: .upToNextOption, help: "Arguments to pass to the application on launch when using --url.")
	var launchArguments: [String] = []

	func run() throws {
		guard url != nil || configuration != nil else {
			throw ValidationError("You must specify one of --url or --configuration.")
		}

		guard url == nil || configuration == nil else {
			throw ValidationError("You must specify only one of --url or --configuration, but not both.")
		}

		if configuration != nil, !launchArguments.isEmpty {
			throw ValidationError("--launch-arguments can only be used with --url. When using --configuration, launch arguments are specified in the configuration file.")
		}

		let notification: (any TophatInterProcessNotification)? = if let url {
			TophatInstallURLNotification(
				payload: TophatInstallURLNotification.Payload(
					url: url,
					launchArguments: launchArguments
				)
			)
		} else if let configuration {
			TophatInstallConfigurationNotification(
				payload: TophatInstallConfigurationNotification.Payload(
					installRecipes: try JSONDecoder().decode(
						[UserSpecifiedRecipeConfiguration].self,
						from: Data(contentsOf: configuration)
					)
				)
			)
		} else {
			nil
		}

		if let notification {
			TophatInterProcessNotifier().send(notification: notification)
		}
	}
}
