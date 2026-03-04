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

	@Option(name: .long, help: "The identifier of the device to install to (UDID for Apple devices, serial for Android). Overrides the device selection in the Tophat UI.")
	var deviceId: String?

	func run() async throws {
		checkIfHostAppIsRunning()

		let service = TophatRemoteControlService()
		let urlParsedAsArgument = URL(argument: idOrPath)

		guard
			let urlParsedAsArgument,
			let scheme = urlParsedAsArgument.scheme,
			urlParsedAsArgument.isFileURL ? urlParsedAsArgument.pathExtension != "" : (scheme.hasPrefix("http") || scheme == "tophat")
		else {
			try assertLaunchArgumentsEmpty()
			try await service.send(request: InstallFromQuickLaunchRequest(quickLaunchEntryID: idOrPath, deviceIdentifier: deviceId), timeout: 60)
			return
		}

		if urlParsedAsArgument.scheme == "tophat" {
			try assertLaunchArgumentsEmpty()
			let recipes = try parseTophatURL(urlParsedAsArgument)
			let request = InstallFromRecipesRequest(recipes: recipes, deviceIdentifier: deviceId)
			try await service.send(request: request, timeout: 60)
			return
		}

		if urlParsedAsArgument.pathExtension == "json" {
			try assertLaunchArgumentsEmpty()

			let request = InstallFromRecipesRequest(
				recipes: try JSONDecoder().decode(
					[UserSpecifiedRecipeConfiguration].self,
					from: Data(contentsOf: urlParsedAsArgument)
				),
				deviceIdentifier: deviceId
			)

			try await service.send(request: request, timeout: 60)
			return
		}

		let request = InstallFromURLRequest(
			url: urlParsedAsArgument,
			launchArguments: launchArguments,
			deviceIdentifier: deviceId
		)

		try await service.send(request: request, timeout: 60)
	}

	private func parseTophatURL(_ url: URL) throws -> [UserSpecifiedRecipeConfiguration] {
		guard url.host() == "install" else {
			throw ValidationError("Unsupported tophat URL: \(url.absoluteString)")
		}

		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			throw ValidationError("Malformed tophat URL: \(url.absoluteString)")
		}

		let artifactProviderID = url.lastPathComponent
		let queryItems = components.queryItems ?? []

		let binnedQueryItemValues = Dictionary(grouping: queryItems) { $0.name }
			.mapValues { items in items.compactMap(\.value) }

		let reservedKeys: Set<String> = ["platform", "destination", "arguments"]

		let parameterQueryItemValues = binnedQueryItemValues.filter { !reservedKeys.contains($0.key) }

		let valueCount = parameterQueryItemValues.values.first?.count ?? 0

		if valueCount == 0, binnedQueryItemValues.values.contains(where: { $0.count > 1 }) {
			throw ValidationError("Malformed tophat URL: \(url.absoluteString)")
		}

		if parameterQueryItemValues.isEmpty {
			return [
				recipeConfiguration(
					at: 0,
					in: binnedQueryItemValues,
					artifactProviderID: artifactProviderID
				)
			]
		}

		guard parameterQueryItemValues.allSatisfy({ $1.count == valueCount }) else {
			throw ValidationError("Malformed tophat URL: \(url.absoluteString)")
		}

		return (0..<valueCount).map { index in
			recipeConfiguration(
				at: index,
				in: binnedQueryItemValues,
				artifactProviderID: artifactProviderID
			)
		}
	}

	private func recipeConfiguration(
		at index: Int,
		in binnedQueryItemValues: [String: [String]],
		artifactProviderID: String
	) -> UserSpecifiedRecipeConfiguration {
		let reservedKeys: Set<String> = ["platform", "destination", "arguments"]

		let parameters: [String: String] = binnedQueryItemValues.reduce(into: [:]) { partialResult, item in
			if !reservedKeys.contains(item.key) {
				partialResult[item.key] = item.value[safe: index] ?? item.value[safe: 0] ?? ""
			}
		}

		let platformHint: Platform = if let platformString = binnedQueryItemValues["platform"]?[safe: index] {
			Platform(rawValue: platformString) ?? .unknown
		} else {
			.unknown
		}

		let destinationHint: DeviceType? = if let destinationString = binnedQueryItemValues["destination"]?[safe: index] {
			destinationString == "device" ? .device : .simulator
		} else {
			nil
		}

		let launchArguments = binnedQueryItemValues["arguments"]?[safe: index]?
			.split(separator: ",", omittingEmptySubsequences: true)
			.map(String.init) ?? []

		return UserSpecifiedRecipeConfiguration(
			artifactProviderID: artifactProviderID,
			artifactProviderParameters: parameters,
			launchArguments: launchArguments,
			platformHint: platformHint,
			destinationHint: destinationHint
		)
	}

	private func assertLaunchArgumentsEmpty() throws {
		guard launchArguments.isEmpty else {
			throw ValidationError("--launch-arguments can only be used when specifying the path to an artifact and now when specifying an identifier or path to a JSON configuration file.")
		}
	}
}
