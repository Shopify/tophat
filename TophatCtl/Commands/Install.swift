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

To target a specific device by name and runtime version:

[
  {
	"artifactProviderID": "<example>",
	"artifactProviderParameters": {},
	"launchArguments": [],
	"device": {
	  "name": "iPhone 16 Pro",
	  "platform": "ios",
	  "runtimeVersion": "18.2"
	}
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
			let reply = try await service.send(request: InstallFromQuickLaunchRequest(quickLaunchEntryID: idOrPath), timeout: 60)

			if let errorMessage = reply.errorMessage {
				print(errorMessage)
				throw ExitCode.failure
			}

			return
		}

		if urlParsedAsArgument.pathExtension == "json" {
			try assertLaunchArgumentsEmpty()

			let recipes = try JSONDecoder().decode(
				[UserSpecifiedInstallRecipeConfiguration].self,
				from: Data(contentsOf: urlParsedAsArgument)
			)

			for recipe in recipes {
				if recipe.device != nil, recipe.platformHint != nil || recipe.destinationHint != nil {
					throw ValidationError("Cannot specify both device and platformHint or destinationHint.")
				}
			}

			let request = InstallFromRecipesRequest(recipes: recipes)
			let reply = try await service.send(request: request, timeout: 60)

			if let errorMessage = reply.errorMessage {
				print(errorMessage)
				throw ExitCode.failure
			}

			return
		}

		let request = InstallFromURLRequest(
			url: urlParsedAsArgument,
			launchArguments: launchArguments
		)

		let reply = try await service.send(request: request, timeout: 60)
		if let errorMessage = reply.errorMessage {
			print(errorMessage)
			throw ExitCode.failure
		}
	}

	private func assertLaunchArgumentsEmpty() throws {
		guard launchArguments.isEmpty else {
			throw ValidationError("--launch-arguments can only be used when specifying the path to an artifact and now when specifying an identifier or path to a JSON configuration file.")
		}
	}
}
