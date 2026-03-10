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

	func callAsFunction(quickLaunchEntry entry: QuickLaunchEntry) async {
		let context = OperationContext(quickLaunchEntryID: entry.id, applicationDisplayName: entry.name)
		await callAsFunction(recipes: entry.installRecipes, context: context)
	}

	func callAsFunction(artifactURL: URL, launchArguments: [String] = [], context: OperationContext? = nil) async {
		await callAsFunction(
			recipes: [InstallRecipe(source: artifactURL.artifactSource, launchArguments: launchArguments)],
			context: context
		)
	}

	func callAsFunction(recipes: [InstallRecipe], context: OperationContext? = nil) async {
		do {
			try await installCoordinator.install(recipes: recipes, context: context)
		} catch {
			ErrorNotifier().notify(error: error)
		}
	}
}

extension EnvironmentValues {
	@Entry var launchApp: LaunchAppAction?
}
