//
//  InstallationTicketMachine.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-10-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

protocol ApplicationDownloading: Sendable {
	func download(from source: ArtifactSource, context: OperationContext?) async throws -> Application
	func cleanUp() async throws
}

extension ApplicationDownloading {
	func download(using source: ArtifactSource) async throws -> Application {
		try await download(from: source, context: nil)
	}
}

protocol DeviceSelecting: Sendable {
	@MainActor var selectedDevices: [Device] { get }
}

/// A mechanism for producing installation tickets for selected devices based on the information
/// provided by installation recipes.
struct InstallationTicketMachine {
	typealias TicketSequence = AsyncThrowingStream<Ticket, Error>

	private let deviceSelector: DeviceSelecting
	private let applicationDownloader: ApplicationDownloading

	/// Creates a new instance of the processor.
	/// - Parameters:
	///   - deviceSelector: An instance that provides user-selected devices.
	///   - applicationDownloader: An instance that provides downloading capability
	init(deviceSelector: DeviceSelecting, applicationDownloader: ApplicationDownloading) {
		self.deviceSelector = deviceSelector
		self.applicationDownloader = applicationDownloader
	}

	/// Begins producing tickets for the provided recipes and returns them in an asynchronous
	/// sequence.
	/// - Parameter recipes: The recipes to be processed.
	/// - Returns: An asynchronous sequence of tickets.
	func process(recipes: [InstallRecipe], context: OperationContext? = nil) -> TicketSequence {
		AsyncThrowingStream { continuation in
			Task {
				do {
					try await process(recipes: recipes, continuation: continuation, context: context)
					continuation.finish()
				} catch {
					continuation.finish(throwing: error)
				}
			}
		}
	}

	private func process(recipes: [InstallRecipe], continuation: TicketSequence.Continuation, context: OperationContext?) async throws {
		let selectedDevices = await deviceSelector.selectedDevices

		guard !selectedDevices.isEmpty else {
			throw InstallationTicketMachineError.noSelectedDevices
		}

		let state = RecipeProcessingState()

		for recipe in recipes {
			if let platform = recipe.platformHint, let destination = recipe.destinationHint {
				await state.track(providedDestinations: [destination], for: platform)
			}
		}

		try await withThrowingTaskGroup(of: Void.self) { group in
			for device in selectedDevices {
				group.addTask {
					// If this ends up in the else case, it means there was not enough
					// information in any recipe to be confident that the build will install
					// to the device.
					if let recipe = compatibleRecipeBasedOnHints(for: device, in: recipes) {
						let ticket = Ticket(
							device: device,
							artifactLocation: .remote(source: recipe.source),
							launchArguments: recipe.launchArguments,
							deepLink: recipe.deepLink
						)

						await state.incrementProcessedTicketCount()
						continuation.yield(ticket)
					} else {
						recipeLoop: for recipe in recipes where recipe.platformHint == nil {
							if let destinationHint = recipe.destinationHint, device.type != destinationHint {
								continue recipeLoop
							}

							let application = try await applicationDownloader.download(from: recipe.source, context: context)

							await state.track(providedDestinations: application.targets, for: application.platform)

							guard
								device.runtime.platform == application.platform,
								application.targets.contains(device.type)
							else {
								continue recipeLoop
							}

							let ticket = Ticket(
								device: device,
								artifactLocation: .local(application: application),
								launchArguments: recipe.launchArguments,
								deepLink: recipe.deepLink
							)

							await state.incrementProcessedTicketCount()
							continuation.yield(ticket)
						}
					}
				}
			}

			try await group.waitForAll()
		}

		guard await state.processedTicketCount > 0 else {
			throw InstallationTicketMachineError.noCompatibleDevices(providedDestinations: await state.providedDestinations)
		}
	}

	private func compatibleRecipeBasedOnHints(for device: Device, in recipes: [InstallRecipe]) -> InstallRecipe? {
		recipes.first { $0.platformHint == device.runtime.platform && $0.destinationHint == device.type }
		?? recipes.first { $0.platformHint == device.runtime.platform && $0.destinationHint == nil }
	}
}

extension InstallationTicketMachine {
	private actor RecipeProcessingState {
		private(set) var providedDestinations: [Platform: Set<DeviceType>] = [:]
		private(set) var processedTicketCount: Int = 0

		func incrementProcessedTicketCount() {
			processedTicketCount += 1
		}

		func track(providedDestinations destinations: Set<DeviceType>, for platform: Platform) {
			providedDestinations[platform, default: []].formUnion(destinations)
		}
	}

	struct Ticket: Sendable {
		let device: Device
		let artifactLocation: ArtifactLocation
		let launchArguments: [String]
		let deepLink: String?
	}
}

enum InstallationTicketMachineError: Error {
	case noCompatibleDevices(providedDestinations: [Platform: Set<DeviceType>])
	case noSelectedDevices
}

extension DeviceSelectionManager: DeviceSelecting {}
