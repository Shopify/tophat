//
//  UserSpecifiedQuickLaunchEntryConfiguration.swift
//  TophatUtilities
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

public struct UserSpecifiedQuickLaunchEntryConfiguration: Codable {
	public typealias Source = UserSpecifiedInstallRecipe

	public let id: String
	public let name: String
	public let sources: [Source]
}
