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

private let discussion = """
When specifying the path to a JSON configuration file, use the following format to specify recipes:

[
  {
	"artifactProviderID": "<example>",
	"artifactProviderParameters": {},
	"launchArguments": [],
	"platformHint": "ios",
	"destinationHint": "simulator"
  }
]
"""

struct Install: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Installs an application.",
		discussion: discussion
	)

	@Argument(help: "The identifier of the Quick Launch entry, local path or URL to an artifact, or local path to a JSON configuration file.")
	var idOrPath: String

	@Option(parsing: .upToNextOption, help: "Arguments to pass to the application on launch when an artifact is provided.")
	var launchArguments: [String] = []

	func run() async throws {
		checkIfHostAppIsRunning()

		let service = TophatRemoteControlService()
		let urlParsedAsArgument = URL(argument: idOrPath)

		guard
			let urlParsedAsArgument,
			let scheme = urlParsedAsArgument.scheme,
			urlParsedAsArgument.isFileURL ? urlParsedAsArgument.pathExtension != "" : scheme.hasPrefix("http")
		else {
			try assertLaunchArgumentsEmpty()
			try await service.send(request: InstallFromQuickLaunchRequest(quickLaunchEntryID: idOrPath), timeout: 60)
			return
		}

		if urlParsedAsArgument.pathExtension == "json" {
			try assertLaunchArgumentsEmpty()

			let request = InstallFromRecipesRequest(
				recipes: try JSONDecoder().decode(
					[UserSpecifiedRecipeConfiguration].self,
					from: Data(contentsOf: urlParsedAsArgument)
				)
			)

			try await service.send(request: request, timeout: 60)
			return
		}

		let request = InstallFromURLRequest(
			url: urlParsedAsArgument,
			launchArguments: launchArguments
		)

		try await service.send(request: request, timeout: 60)
	}

	private func assertLaunchArgumentsEmpty() throws {
		guard launchArguments.isEmpty else {
			throw ValidationError("--launch-arguments can only be used when specifying the path to an artifact and now when specifying an identifier or path to a JSON configuration file.")
		}
	}
}
