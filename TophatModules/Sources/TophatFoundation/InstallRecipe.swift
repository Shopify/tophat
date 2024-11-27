//
//  InstallRecipe.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2024-09-27.
//  Copyright © 2024 Shopify. All rights reserved.
//

/// Structure representing instructions for installing a artifact from a remote source.
public struct InstallRecipe: Equatable, Hashable, Codable {
	/// The source of the artifact to install.
	public let source: RemoteArtifactSource

	/// The arguments to pass to the application at launch.
	public let launchArguments: [String]

	/// The expected platform of the artifact, used to preheat the target device.
	public let platformHint: Platform?

	/// The expected destination of the artifact, used to preheat the target device.
	public let destinationHint: DeviceType?

	public init(
		source: RemoteArtifactSource,
		launchArguments: [String] = [],
		platformHint: Platform? = nil,
		destinationHint: DeviceType? = nil
	) {
		self.source = source
		self.launchArguments = launchArguments
		self.platformHint = platformHint
		self.destinationHint = destinationHint
	}
}
