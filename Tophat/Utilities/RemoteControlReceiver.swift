//
//  RemoteControlReceiver.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import TophatControlServices
@_spi(TophatKitInternal) import TophatKit

protocol RemoteControlReceiverDelegate: AnyObject, Sendable {
	func remoteControlReceiver(didReceiveRequestToAddQuickLaunchEntry quickLaunchEntry: QuickLaunchEntry)
	func remoteControlReceiver(didReceiveRequestToRemoveQuickLaunchEntryWithIdentifier quickLaunchEntryIdentifier: QuickLaunchEntry.ID)
	func remoteControlReceiver(didReceiveRequestToLaunchApplicationWithRecipes recipes: [InstallRecipe]) async
	func remoteControlReceiver(didOpenURL url: URL, launchArguments: [String]) async
}

struct RemoteControlReceiver {
	private let service = TophatRemoteControlService()
	private let extensionHost: ExtensionHost

	init(extensionHost: ExtensionHost) {
		self.extensionHost = extensionHost
	}

	func start(delegate: RemoteControlReceiverDelegate) {
		Task {
			for await request in service.requests(for: InstallFromURLRequest.self) {
				let requestValue = request.value

				await delegate.remoteControlReceiver(didOpenURL: requestValue.url, launchArguments: requestValue.launchArguments)
				request.reply(.init())
			}
		}

		Task {
			for await request in service.requests(for: InstallFromRecipesRequest.self) {
				let requestValue = request.value

				let recipes = requestValue.recipes.map { recipe in
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

				await delegate.remoteControlReceiver(didReceiveRequestToLaunchApplicationWithRecipes: recipes)
				request.reply(.init())
			}
		}

		Task {
			for await request in service.requests(for: AddQuickLaunchEntryRequest.self) {
				let requestValue = request.value

				let configuration = requestValue.configuration

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

				delegate.remoteControlReceiver(didReceiveRequestToAddQuickLaunchEntry: quickLaunchEntry)
			}
		}

		Task {
			for await request in service.requests(for: RemoveQuickLaunchEntryRequest.self) {
				let requestValue = request.value
				delegate.remoteControlReceiver(
					didReceiveRequestToRemoveQuickLaunchEntryWithIdentifier: requestValue.quickLaunchEntryID
				)
			}
		}

		Task {
			for await request in service.requests(for: ListProvidersRequest.self) {
				let specifications = await extensionHost.availableExtensions.map(\.specification)
				var providers: [ListProvidersRequest.Reply.Provider] = []

				for specification in specifications {
					providers.append(
						contentsOf: specification.artifactProviders.map { artifactProvider in
							.init(
								id: artifactProvider.id,
								title: artifactProvider.title.key,
								extensionTitle: specification.title.key,
								parameters: artifactProvider.parameters.map { parameter in
									.init(key: parameter.key, title: parameter.title.key)
								}
							)
						}
					)
				}

				request.reply(.init(providers: providers))
			}
		}
	}
}
