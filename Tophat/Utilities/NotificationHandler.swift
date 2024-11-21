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
	func notificationHandler(didReceiveRequestToAddPinnedApplication pinnedApplication: PinnedApplication)
	func notificationHandler(didReceiveRequestToRemovePinnedApplicationWithIdentifier pinnedApplicationIdentifier: PinnedApplication.ID)
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
			.publisher(for: TophatAddPinnedApplicationNotification.self)
			.sink { [weak self] payload in
				let configuration = payload.configuration

				let pinnedApplication = PinnedApplication(
					id: configuration.id,
					name: configuration.name,
					recipes: configuration.sources.map { source in
						let artifactProviderMetadata = ArtifactProviderMetadata(
							id: source.artifactProviderID,
							parameters: source.artifactProviderParameters
						)

						return InstallRecipe(
							source: .artifactProvider(metadata: artifactProviderMetadata),
							launchArguments: source.launchArguments,
							platformHint: source.platformHint,
							destinationHint: source.destinationHint
						)
					}
				)

				self?.delegate?.notificationHandler(didReceiveRequestToAddPinnedApplication: pinnedApplication)
			}
			.store(in: &cancellables)

		notifier
			.publisher(for: TophatRemovePinnedApplicationNotification.self)
			.sink { [weak self] payload in
				self?.delegate?.notificationHandler(didReceiveRequestToRemovePinnedApplicationWithIdentifier: payload.id)
			}
			.store(in: &cancellables)
	}
}
