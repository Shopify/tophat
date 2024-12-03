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
import TophatControlServices

struct Install: AsyncParsableCommand {
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

	func run() async throws {
		guard url != nil || configuration != nil else {
			throw ValidationError("You must specify one of --url or --configuration.")
		}

		guard url == nil || configuration == nil else {
			throw ValidationError("You must specify only one of --url or --configuration, but not both.")
		}

		if configuration != nil, !launchArguments.isEmpty {
			throw ValidationError("--launch-arguments can only be used with --url. When using --configuration, launch arguments are specified in the configuration file.")
		}

		let service = TophatRemoteControlService()

		if let url {
			let request = InstallFromURLRequest(
				url: url,
				launchArguments: launchArguments
			)

			try service.send(request: request)

		} else if let configuration {
			let request = InstallFromRecipesRequest(
				recipes: try JSONDecoder().decode(
					[UserSpecifiedRecipeConfiguration].self,
					from: Data(contentsOf: configuration)
				)
			)

			try service.send(request: request)
		}
	}
}
