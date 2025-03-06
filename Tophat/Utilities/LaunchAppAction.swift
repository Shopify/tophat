//
//  LaunchAppAction.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-20.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct LaunchAppAction {
	private let installCoordinator: InstallCoordinator

	init(installCoordinator: InstallCoordinator) {
		self.installCoordinator = installCoordinator
	}

	func callAsFunction(quickLaunchEntry entry: QuickLaunchEntry) async throws {
		let context = OperationContext(quickLaunchEntryID: entry.id, applicationDisplayName: entry.name)

		let recipes = entry.recipes.map { source in
			InstallRecipe(
				source: .artifactProvider(
					metadata: ArtifactProviderMetadata(
						id: source.artifactProviderID,
						parameters: source.artifactProviderParameters
					)
				),
				launchArguments: source.launchArguments,
				platformHint: source.platformHint,
				destinationHint: source.destinationHint
			)
		}

		try await callAsFunction(recipes: recipes, context: context)
	}

	func callAsFunction(artifactURL: URL, launchArguments: [String] = [], context: OperationContext? = nil) async throws {
		let source: ArtifactSource = if artifactURL.isFileURL {
			.file(url: artifactURL)
		} else {
			.artifactProvider(
				metadata: ArtifactProviderMetadata(
					id: "http",
					parameters: ["url": artifactURL.absoluteString]
				)
			)
		}

		try await callAsFunction(
			recipes: [InstallRecipe(source: source, launchArguments: launchArguments)],
			context: context
		)
	}

	func callAsFunction(recipes: [InstallRecipe], context: OperationContext? = nil) async throws {
		do {
			try await installCoordinator.install(recipes: recipes, context: context)
		} catch {
			throw LaunchAppActionError.test
//			ErrorNotifier().notify(error: error)
		}
	}
}

extension EnvironmentValues {
	@Entry var launchApp: LaunchAppAction?
}

enum LaunchAppActionError: Error {
	case test
}
