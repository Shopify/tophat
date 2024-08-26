//
//  InstallCoordinator.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-25.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

final class InstallCoordinator {
	weak var delegate: InstallCoordinatorDelegate?

	private unowned let deviceManager: DeviceManager
	private unowned let pinnedApplicationState: PinnedApplicationState
	private unowned let taskStatusReporter: TaskStatusReporter
	private let launchRequestBuilder: LaunchRequestBuilder

	init(
		deviceManager: DeviceManager,
		deviceSelectionManager: DeviceSelectionManager,
		pinnedApplicationState: PinnedApplicationState,
		taskStatusReporter: TaskStatusReporter
	) {
		self.deviceManager = deviceManager
		self.pinnedApplicationState = pinnedApplicationState
		self.launchRequestBuilder = LaunchRequestBuilder(deviceSelectionManager: deviceSelectionManager)
		self.taskStatusReporter = taskStatusReporter
	}

	/// Downloads, installs, and launches an artifact set on a device matching a given platform.
	///
	/// If an appropriate device is found for the artifact set in advance, the device is booted in parallel
	/// with the download process to improve completion time.
	///
	/// - Parameters:
	///   - artifactSet: The artifact set to launch.
	///   - platform: The platform to launch on.
	///   - context: Additional metadata for the operation.
	func launch(artifactSet: ArtifactSet, on platform: Platform, context: LaunchContext? = nil) async throws {
		await preflightInstallation(context: context)

		do {
			let launchRequest = try launchRequestBuilder.createRequest(for: artifactSet, platform: platform)
			try await launch(artifactURL: launchRequest.launchable.url, device: launchRequest.device, context: context)

		} catch let error {
			notifyError(error: error, platform: platform)
			throw error
		}
	}

	/// Downloads, installs, and launches an artifact from an artifact provider endpoint.
	///
	/// If an appropriate device is found for the artifact set in advance, the device is booted in parallel
	/// with the download process to improve completion time.
	///
	/// - Parameters:
	///   - artifactProviderURL: The URL of the API that returns artifacts.
	///   - context: Additional metadata for the operation.
	func launch(artifactProviderURL: URL, context: LaunchContext? = nil) async throws {
		await preflightInstallation(context: context)

		let response: ArtifactProviderResponse

		do {
			response = try await ArtifactProvider(url: artifactProviderURL).fetchArtifacts()
		} catch let error {
			notifyError(error: error)
			throw error
		}

		do {
			let launchRequest = try launchRequestBuilder.createRequest(for: response)
			try await launch(
				artifactURL: launchRequest.launchable.url,
				device: launchRequest.device,
				context: context ?? LaunchContext(appName: response.name)
			)
		} catch let error {
			notifyError(error: error, platform: response.platform)
			throw error
		}
	}

	/// Downloads, installs, and launches an artifact from a local or remote URL.
	///
	/// The device to boot is not known ahead of time—it will be booted after the application is downloaded
	/// and unpacked. To improve user experience, prefer ``launch(artifactSet:on:context:)``
	/// where possible so that devices are prepared ahead of time.
	///
	/// - Parameters:
	///   - artifactURL: The URL of the artifact to launch.
	///   - context: Additional metadata for the operation.
	func launch(artifactURL: URL, context: LaunchContext? = nil) async throws {
		do {
			try await launch(artifactURL: artifactURL, device: nil, context: context)

		} catch let error {
			notifyError(error: error)
			throw error
		}
	}

	private func launch(artifactURL: URL, device: Device?, context: LaunchContext? = nil) async throws {
		guard await validateHostTrust(artifactURL: artifactURL) == .allow else {
			return
		}

		let fetchArtifact = FetchArtifactTask(taskStatusReporter: taskStatusReporter, pinnedApplicationState: pinnedApplicationState, context: context)
		let prepareDevice = PrepareDeviceTask(taskStatusReporter: taskStatusReporter)

		async let futureFetchArtifactResult = fetchArtifact(at: artifactURL)

		if let device = device {
			// We've been told what device we need in advance, so boot it in parallel to save time.
			async let futurePrepareDeviceResult = prepareDevice(device: device)

			let (fetchArtifactResult, prepareDeviceResult) = await (
				try futureFetchArtifactResult,
				try futurePrepareDeviceResult
			)

			if !prepareDeviceResult.deviceWasColdBooted {
				// If the device wasn't cold booted, bring it to the foreground later in the process.
				log.info("Bringing device to foreground")

				// This is a non-critical feature, it is allowed to fail in case the
				// user hasn't accepted permissions.
				try? device.focus()
			}

			try await install(application: fetchArtifactResult.application, on: device, context: context)

		} else {
			// We don't know what device we will need. Determine the device based on the downloaded application.
			await preflightInstallation(context: context)
			let application = try await futureFetchArtifactResult.application
			let device = try launchRequestBuilder.createRequest(for: application).device

			try await prepareDevice(device: device)
			try await install(application: application, on: device, context: context)
		}
	}

	private func install(application: Application, on device: Device, context: LaunchContext? = nil) async throws {
		let installApplication = InstallApplicationTask(taskStatusReporter: taskStatusReporter, context: context)
		try await installApplication(application: application, device: device)

		delegate?.installCoordinator(didSuccessfullyInstallAppForPlatform: application.platform)
	}

	private func preflightInstallation(context: LaunchContext?) async {
		taskStatusReporter.notify(message: "Preparing to install \(context?.appName ?? "application")…")
		await deviceManager.loadDevices()
	}

	private func validateHostTrust(artifactURL: URL) async -> HostTrustResult {
		if artifactURL.isFileURL {
			return .allow
		}

		guard let host = artifactURL.host() else {
			return .block
		}

		return await delegate?.installCoordinator(didPromptToAllowUntrustedHost: host) ?? .block
	}

	private func notifyError(error: Error, platform: Platform? = nil) {
		log.error("An error occurred while installing the application: \(error.localizedDescription)")
		delegate?.installCoordinator(didFailToInstallAppForPlatform: platform)
	}
}
