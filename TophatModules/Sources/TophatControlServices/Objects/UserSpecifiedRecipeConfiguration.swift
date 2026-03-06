//
//  UserSpecifiedRecipeConfiguration.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import TophatFoundation

public struct UserSpecifiedInstallRecipeConfiguration: Codable, Sendable {
	public let artifactProviderID: String
	public let artifactProviderParameters: [String: String]
	public let launchArguments: [String]
	public let platformHint: Platform?
	public let destinationHint: DeviceType?
	public let device: Device?

	public struct Device: Codable, Sendable {
		public let name: String
		public let platform: Platform
		public let runtimeVersion: String
	}
}

public struct UserSpecifiedQuickLaunchRecipeConfiguration: Codable, Sendable {
	public let artifactProviderID: String
	public let artifactProviderParameters: [String: String]
	public let launchArguments: [String]
	public let platformHint: Platform
	public let destinationHint: DeviceType?
}
