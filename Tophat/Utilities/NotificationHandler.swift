//
//  NotificationHandler.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import Combine
import TophatFoundation
import TophatUtilities

protocol NotificationHandlerDelegate: AnyObject {
	func notificationHandler(didReceiveRequestToAddQuickLaunchEntry quickLaunchEntry: QuickLaunchEntry)
	func notificationHandler(didReceiveRequestToRemoveQuickLaunchEntryWithIdentifier quickLaunchEntryIdentifier: QuickLaunchEntry.ID)
	func notificationHandler(didReceiveRequestToLaunchApplicationWithRecipes recipes: [InstallRecipe])
	func notificationHandler(didOpenURL url: URL, launchArguments: [String])
}

final class NotificationHandler {
	weak var delegate: NotificationHandlerDelegate?

	private let notifier = TophatInterProcessNotifier()
	private var cancellables: Set<AnyCancellable> = []

	init() {
		notifier
			.publisher(for: TophatInstallURLNotification.self)
			.sink { [weak self] payload in
				self?.delegate?.notificationHandler(didOpenURL: payload.url, launchArguments: payload.launchArguments)
			}
			.store(in: &cancellables)

		notifier
			.publisher(for: TophatInstallConfigurationNotification.self)
			.sink { [weak self] payload in
				let recipes = payload.installRecipes.map { recipe in
					let artifactProviderMetadata = ArtifactProviderMetadata(
						id: recipe.artifactProviderID,
						parameters: recipe.artifactProviderParameters
					)

					return InstallRecipe(
						source: .artifactProvider(metadata: artifactProviderMetadata),
						launchArguments: recipe.launchArguments,
						platformHint: recipe.platformHint,
						destinationHint: recipe.destinationHint
					)
				}

				self?.delegate?.notificationHandler(didReceiveRequestToLaunchApplicationWithRecipes: recipes)
			}
			.store(in: &cancellables)

		notifier
			.publisher(for: TophatAddQuickLaunchEntryNotification.self)
			.sink { [weak self] payload in
				let configuration = payload.configuration

				let quickLaunchEntry = QuickLaunchEntry(
					id: configuration.id,
					name: configuration.name,
					recipes: configuration.recipes.map { source in
						let artifactProviderMetadata = ArtifactProviderMetadata(
							id: source.artifactProviderID,
							parameters: source.artifactProviderParameters
						)

						return QuickLaunchEntryRecipe(
							artifactProviderID: artifactProviderMetadata.id,
							artifactProviderParameters: artifactProviderMetadata.parameters,
							launchArguments: source.launchArguments,
							platformHint: source.platformHint,
							destinationHint: source.destinationHint
						)
					}
				)

				self?.delegate?.notificationHandler(didReceiveRequestToAddQuickLaunchEntry: quickLaunchEntry)
			}
			.store(in: &cancellables)

		notifier
			.publisher(for: TophatRemoveQuickLaunchEntryNotification.self)
			.sink { [weak self] payload in
				self?.delegate?.notificationHandler(didReceiveRequestToRemoveQuickLaunchEntryWithIdentifier: payload.id)
			}
			.store(in: &cancellables)
	}
}
