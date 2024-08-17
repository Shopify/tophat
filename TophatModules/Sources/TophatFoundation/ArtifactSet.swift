//
//  ArtifactSet.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-11-17.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// Structure representing a set of artifacts to use for launching.
public struct ArtifactSet {
	/// The provided artifacts.
	public let artifacts: [Artifact]

	/// The targets for which this artifact set is able to provide artifacts.
	public var targets: Set<DeviceType> {
		Set(artifacts.flatMap { $0.targets })
	}

	public init(artifacts: [Artifact]) {
		self.artifacts = artifacts
	}
}

public extension ArtifactSet {
	func artifacts(targeting target: DeviceType) -> [Artifact] {
		artifacts.filter { $0.targets.contains(target) }
	}
}
