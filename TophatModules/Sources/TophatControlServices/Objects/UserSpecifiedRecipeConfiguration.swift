//
//  UserSpecifiedRecipeConfiguration.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import TophatFoundation

public struct UserSpecifiedRecipeConfiguration: Codable, Sendable {
	public let artifactProviderID: String
	public let artifactProviderParameters: [String: String]
	public let launchArguments: [String]
	public let platformHint: Platform
	public let destinationHint: DeviceType?
}
