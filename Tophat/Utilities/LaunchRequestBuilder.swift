//
//  LaunchRequestBuilder.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-17.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

/// Utility class that coordinates selecting the correct devices and artifact to use when launching an application.
final class LaunchRequestBuilder {
	private unowned let deviceSelectionManager: DeviceSelectionManager

	init(deviceSelectionManager: DeviceSelectionManager) {
		self.deviceSelectionManager = deviceSelectionManager
	}

	/// Determines which device to run on, which artifact to select for the device, and returns a launch request.
	/// - Parameter artifactSet: The artifact set to read artifact details from.
	/// - Returns: A launch containing the parameters of the launch operation.
	func createRequest(for artifactSet: ArtifactSet, platform: Platform) throws -> LaunchRequest {
		guard let device = getTargetDevice(for: platform) else {
			throw LaunchRequestBuilderError.failedToFindCompatibleDevice(
				platform: platform,
				availableTargets: artifactSet.targets
			)
		}

		guard let artifact = artifactSet.artifacts(targeting: device.type).first else {
			throw LaunchRequestBuilderError.failedToFindCompatibleArtifact(
				device: device,
				availableTargets: artifactSet.targets
			)
		}

		return LaunchRequest(launchable: artifact, device: device)
	}

	func createRequest(for application: Application) throws -> LaunchRequest {
		let platform = application.platform
		let targets = application.targets

		guard let device = getTargetDevice(for: platform) else {
			throw LaunchRequestBuilderError.failedToFindCompatibleDevice(
				platform: platform,
				availableTargets: targets
			)
		}

		guard targets.contains(device.type) else {
			throw LaunchRequestBuilderError.failedToFindCompatibleArtifact(
				device: device,
				availableTargets: targets
			)
		}

		return LaunchRequest(launchable: application, device: device)
	}

	private func getTargetDevice(for platform: Platform) -> Device? {
		deviceSelectionManager.selectedDevices.first { $0.runtime.platform == platform }
	}
}

enum LaunchRequestBuilderError: Error {
	case failedToFindCompatibleDevice(platform: Platform, availableTargets: Set<DeviceType>)
	case failedToFindCompatibleArtifact(device: Device, availableTargets: Set<DeviceType>)
}
