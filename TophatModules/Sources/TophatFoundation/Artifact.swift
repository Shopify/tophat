//
//  Artifact.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-25.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// Structure representing a tophat-able artifact.
public struct Artifact: Launchable, Codable {
	/// The location of the remote artifact.
	public let url: URL

	/// The target devices of the artifact.
	public let targets: Set<DeviceType>

	public init(url: URL, targets: Set<DeviceType>) {
		self.url = url
		self.targets = targets
	}
}
