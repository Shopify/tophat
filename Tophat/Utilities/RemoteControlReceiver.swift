//
//  RemoteControlReceiver.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import SwiftData
import TophatFoundation
import TophatControlServices
@_spi(TophatKitInternal) import TophatKit

protocol RemoteControlReceiverDelegate: AnyObject, Sendable {
	func remoteControlReceiver(didReceiveRequestToAddQuickLaunchEntry quickLaunchEntry: QuickLaunchEntry)
	func remoteControlReceiver(didReceiveRequestToRemoveQuickLaunchEntryWithIdentifier quickLaunchEntryIdentifier: QuickLaunchEntry.ID)
	func remoteControlReceiver(didReceiveRequestToLaunchApplicationWithRecipes recipes: [InstallRecipe]) async throws
	func remoteControlReceiver(didReceiveRequestToLaunchQuickLaunchEntryWithIdentifier quickLaunchEntryIdentifier: QuickLaunchEntry.ID) async throws
	func remoteControlReceiver(didOpenURL url: URL, launchArguments: [String]) async throws
}

struct RemoteControlReceiver {
	private let service = TophatRemoteControlService()
	private let extensionHost: ExtensionHost
	private let modelContainer: ModelContainer
	private let deviceEnumerator: DeviceListLoading

	init(extensionHost: ExtensionHost, modelContainer: ModelContainer, deviceEnumerator: DeviceListLoading) {
		self.extensionHost = extensionHost
		self.modelContainer = modelContainer
		self.deviceEnumerator = deviceEnumerator
	}

	private func errorMessage(for error: Error) -> String {
		var message = String(describing: FormattedError(error))

		if let technicalDetails = (error as? DiagnosticError)?.technicalDetails {
			message += "\n\nUnderlying Error:\n\n\(technicalDetails)"
		}

		return message
	}

	func start(delegate: RemoteControlReceiverDelegate) {
		Task {
			for await request in service.requests(for: InstallFromURLRequest.self) {
				let requestValue = request.value

				do {
					try await delegate.remoteControlReceiver(didOpenURL: requestValue.url, launchArguments: requestValue.launchArguments)
					request.reply(.init())
				} catch {
					request.reply(.init(errorMessage: errorMessage(for: error)))
				}
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

					let deviceInfo: InstallRecipe.DeviceInfo? = if let device = recipe.device {
						.specific(InstallRecipe.Device(
							name: device.name,
							platform: device.platform,
							runtimeVersion: .exact(device.runtimeVersion)
						))
					} else {
						.hinted(InstallRecipe.DeviceHints(
							platformHint: recipe.platformHint,
							destinationHint: recipe.destinationHint
						))
					}

					return InstallRecipe(
						source: .artifactProvider(metadata: artifactProviderMetadata),
						launchArguments: recipe.launchArguments,
						deviceInfo: deviceInfo
					)
				}

				do {
					try await delegate.remoteControlReceiver(didReceiveRequestToLaunchApplicationWithRecipes: recipes)
					request.reply(.init())
				} catch {
					request.reply(.init(errorMessage: errorMessage(for: error)))
				}
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

		Task {
			for await request in service.requests(for: ListAppsRequset.self) {
				let fetchDescriptor = FetchDescriptor<QuickLaunchEntry>()
				let context = ModelContext(modelContainer)
				let entries = (try? context.fetch(fetchDescriptor)) ?? []

				request.reply(
					.init(
						apps: entries.map { entry in
							.init(
								id: entry.id,
								name: entry.name,
								platforms: entry.platforms,
								recipeCount: entry.recipes.count
							)
						}
					)
				)
			}
		}

		Task {
			for await request in service.requests(for: ListDevicesRequest.self) {
				await deviceEnumerator.loadDevices()
				let devices = await deviceEnumerator.devices

				var replyDevices: [ListDevicesRequest.Reply.Device] = []

				for device in devices {
					replyDevices.append(
						.init(
							name: device.name,
							type: device.type,
							platform: device.runtime.platform,
							runtimeVersion: device.runtime.version,
							connection: device.connection,
							state: await device.state
						)
					)
				}

				request.reply(.init(devices: replyDevices))
			}
		}

		Task {
			for await request in service.requests(for: InstallFromQuickLaunchRequest.self) {
				do {
					try await delegate.remoteControlReceiver(didReceiveRequestToLaunchQuickLaunchEntryWithIdentifier: request.value.quickLaunchEntryID)
					request.reply(.init())
				} catch {
					request.reply(.init(errorMessage: errorMessage(for: error)))
				}
			}
		}
	}
}
