//
//  InstallCoordinator.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-27.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

protocol DeviceListLoading {
	func loadDevices() async
}

extension DeviceManager: DeviceListLoading {}

/// The object you use to trigger the installation of an application to the selected devices.
///
/// All requests made within a 30-second period are cached if a previous request was
/// made with the same parameters.  After 30 seconds, the cache is destroyed.
actor InstallCoordinator {
	private let artifactDownloader: ArtifactDownloader
	private let deviceListLoader: DeviceListLoading
	private let deviceSelector: DeviceSelecting
	private let taskStatusReporter: TaskStatusReporter

	private var currentSession: InstallSession

	private var idleTimer: Task<Void, Never>?

	init(
		artifactDownloader: ArtifactDownloader,
		deviceListLoader: DeviceListLoading,
		deviceSelector: DeviceSelecting,
		taskStatusReporter: TaskStatusReporter
	) {
		self.artifactDownloader = artifactDownloader
		self.deviceListLoader = deviceListLoader
		self.deviceSelector = deviceSelector
		self.taskStatusReporter = taskStatusReporter

		self.currentSession = InstallSession(
			artifactDownloader: artifactDownloader,
			deviceSelector: deviceSelector,
			taskStatusReporter: taskStatusReporter
		)
	}

	/// Downloads, installs, and launches applications on selected devices.
	///
	/// If an appropriate device is found for a recipe in advance, the device is booted in parallel
	/// with the download process to improve completion time.
	///
	/// - Parameters:
	///   - recipes: A collection of recipes for retrieving applications.
	///   - context: Additional metadata for the operation.
	func install(recipes: [InstallRecipe], context: OperationContext? = nil) async throws {
		if idleTimer == nil {
			observeSessionIdleState()
		}

		taskStatusReporter.notify(message: "Preparing to install \(context?.quickLaunchEntry?.name ?? "application")…")
		await deviceListLoader.loadDevices()

		try await currentSession.install(recipes: recipes, context: context)
	}

	private func createNewSession() async {
		currentSession = InstallSession(
			artifactDownloader: artifactDownloader,
			deviceSelector: deviceSelector,
			taskStatusReporter: taskStatusReporter
		)

		observeSessionIdleState()
	}

	private func observeSessionIdleState() {
		log.info("[InstallCoordinator] Observing install session idle state.")

		idleTimer?.cancel()

		idleTimer = Task {
			var sleepTimer: Task<Void, Never>?

			for await isIdle in currentSession.isIdleUpdates {
				guard isIdle else {
					sleepTimer?.cancel()
					continue
				}

				sleepTimer = Task {
					// A session (and consequently its cache) are valid for 30 seconds.
					try? await Task.sleep(for: .seconds(30))

					if !Task.isCancelled, await currentSession.isIdle {
						log.info("[InstallCoordinator] Current install session expired. Creating next session.")
						await createNewSession()
					}
				}
			}
		}
	}
}
