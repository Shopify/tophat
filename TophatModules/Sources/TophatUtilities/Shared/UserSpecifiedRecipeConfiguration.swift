//
//  UserSpecifiedRecipeConfiguration.swift
//  TophatUtilities
//
//  Created by Lukas Romsicki on 2024-11-21.
//

import TophatFoundation

public struct UserSpecifiedRecipeConfiguration: Codable {
	public let artifactProviderID: String
	public let artifactProviderParameters: [String: String]
	public let launchArguments: [String]
	public let platformHint: Platform
	public let destinationHint: DeviceType?
}
