//
//  InstallCoordinator.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-25.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import SwiftData

final class InstallCoordinator {
	private unowned let deviceManager: DeviceManager
	private unowned let taskStatusReporter: TaskStatusReporter
	private let deviceSelectionManager: DeviceSelectionManager

	private let artifactDownloader: ArtifactDownloader

	init(
		deviceManager: DeviceManager,
		deviceSelectionManager: DeviceSelectionManager,
		taskStatusReporter: TaskStatusReporter,
		extensionHost: ExtensionHost
	) {
		self.deviceManager = deviceManager
		self.deviceSelectionManager = deviceSelectionManager
		self.taskStatusReporter = taskStatusReporter

		self.artifactDownloader = ArtifactDownloader(artifactRetrievalCoordinator: ArtifactRetrievalCoordinator(appExtensionIdentityResolver: extensionHost))
	}

	/// Downloads, installs, and launches applications on selected devices.
	///  
	/// If an appropriate device is found for a recipe in advance, the device is booted in parallel
	/// with the download process to improve completion time.
	///  
	/// - Parameters:
	///   - recipes: A collection of recipes for retrieving builds.
	///   - context: Additional metadata for the operation.
	func install(recipes: [InstallRecipe], context: LaunchContext? = nil) async throws {
		await preflightInstallation(context: context)

		let fetchArtifact = FetchArtifactTask(
			taskStatusReporter: taskStatusReporter,
			artifactDownloader: artifactDownloader,
			context: context
		)

		let machine = InstallationTicketMachine(deviceSelector: deviceSelectionManager, artifactDownloader: fetchArtifact)

		try await withThrowingTaskGroup(of: Void.self) { group in
			for try await ticket in machine.process(recipes: recipes) {
				group.addTask { [weak self] in
					try await self?.install(ticket: ticket, context: context)
				}
			}

			try await group.waitForAll()
		}
	}

	/// Downloads, installs, and launches an artifact from a local or remote URL.
	///
	/// The device to boot is not known ahead of time—it will be booted after the build is downloaded
	/// and unpacked. To improve user experience, prefer ``launch(recipes:context:)``
	/// where possible so that devices are prepared ahead of time.
	///
	/// - Parameters:
	///   - artifactURL: The URL of the artifact to launch.
	///   - context: Additional metadata for the operation.
	func launch(artifactURL: URL, launchArguments: [String] = [], context: LaunchContext? = nil) async throws {
		await preflightInstallation(context: context)

		let fetchArtifact = FetchArtifactTask(
			taskStatusReporter: taskStatusReporter,
			artifactDownloader: artifactDownloader,
			context: context
		)

		let machine = InstallationTicketMachine(deviceSelector: deviceSelectionManager, artifactDownloader: fetchArtifact)

		let source: RemoteArtifactSource = if artifactURL.isFileURL {
			.file(url: artifactURL)
		} else {
			.artifactProvider(
				metadata: ArtifactProviderMetadata(
					id: "http",
					parameters: ["url": artifactURL.absoluteString]
				)
			)
		}

		let recipe = InstallRecipe(
			source: source,
			launchArguments: launchArguments
		)

		for try await ticket in machine.process(recipes: [recipe]) {
			try await install(ticket: ticket)
		}
	}

	private func install(ticket: InstallationTicketMachine.Ticket, context: LaunchContext? = nil) async throws {
		let fetchArtifact = FetchArtifactTask(
			taskStatusReporter: taskStatusReporter,
			artifactDownloader: artifactDownloader,
			context: context
		)

		let prepareDevice = PrepareDeviceTask(taskStatusReporter: taskStatusReporter)

		async let futureFetchArtifactResult = fetchArtifact(from: ticket.artifactLocation)
		async let futurePrepareDeviceResult = prepareDevice(device: ticket.device)

		let (fetchArtifactResult, prepareDeviceResult) = await (
			try futureFetchArtifactResult,
			try futurePrepareDeviceResult
		)

		if !prepareDeviceResult.deviceWasColdBooted {
			// If the device wasn't cold booted, bring it to the foreground later in the process.
			log.info("Bringing device to foreground")

			// This is a non-critical feature, it is allowed to fail in case the
			// user hasn't accepted permissions.
			try? ticket.device.focus()
		}

		let installApplication = InstallApplicationTask(taskStatusReporter: taskStatusReporter, context: context)

		try await installApplication(
			application: fetchArtifactResult.application,
			device: ticket.device,
			launchArguments: ticket.launchArguments
		)
	}

	private func preflightInstallation(context: LaunchContext?) async {
		taskStatusReporter.notify(message: "Preparing to install \(context?.appName ?? "application")…")
		await deviceManager.loadDevices()
	}
}
