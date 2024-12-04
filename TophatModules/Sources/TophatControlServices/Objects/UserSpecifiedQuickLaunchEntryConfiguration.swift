//
//  UserSpecifiedQuickLaunchEntryConfiguration.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

public struct UserSpecifiedQuickLaunchEntryConfiguration: Codable {
	public typealias Recipe = UserSpecifiedRecipeConfiguration

	public let id: String
	public let name: String
	public let recipes: [Recipe]
}
