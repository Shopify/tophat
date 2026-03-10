//
//  InstallRecipe.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2024-09-27.
//  Copyright © 2024 Shopify. All rights reserved.
//

/// Structure representing instructions for installing a artifact from a remote source.
public struct InstallRecipe: Equatable, Hashable, Codable, Sendable {
	/// The source of the artifact to install.
	public let source: ArtifactSource

	/// The arguments to pass to the application at launch.
	public let launchArguments: [String]

	/// Information about the device that the artifact should be installed to.
	public let deviceInfo: DeviceInfo?

	public init(
		source: ArtifactSource,
		launchArguments: [String] = [],
		deviceInfo: DeviceInfo? = nil
	) {
		self.source = source
		self.launchArguments = launchArguments
		self.deviceInfo = deviceInfo
	}
}

public extension InstallRecipe {
	/// Information about the target device.
	///
	/// If more than one device is matched when using ``specific(_:)``, the first match is used.
	enum DeviceInfo: Equatable, Hashable, Codable, Sendable {
		case hinted(DeviceHints)
		case specific(Device)
	}

	/// Structure representing information about the device that the artifact is expected to run on,
	/// used to preheat the target device.
	struct DeviceHints: Equatable, Hashable, Codable, Sendable {
		/// The expected platform of the artifact.
		public let platformHint: Platform?

		/// The expected destination of the artifact.
		public let destinationHint: DeviceType?

		public init(
			platformHint: Platform? = nil,
			destinationHint: DeviceType? = nil
		) {
			self.platformHint = platformHint
			self.destinationHint = destinationHint
		}
	}

	/// A specific device to be used for installation.
	struct Device: Equatable, Hashable, Codable, Sendable {
		/// The name of the device.
		public let name: String
		/// The platform of the device.
		public let platform: Platform
		/// The runtime version of the device.
		public let runtimeVersion: RuntimeVersion

		public init(name: String, platform: Platform, runtimeVersion: RuntimeVersion) {
			self.name = name
			self.platform = platform
			self.runtimeVersion = runtimeVersion
		}
	}
}
