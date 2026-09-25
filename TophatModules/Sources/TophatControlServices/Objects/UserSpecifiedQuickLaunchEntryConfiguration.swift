//
//  UserSpecifiedQuickLaunchEntryConfiguration.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import TophatFoundation

public struct UserSpecifiedQuickLaunchEntryConfiguration: Codable, Sendable {
	public typealias Recipe = UserSpecifiedQuickLaunchRecipeConfiguration

	public let id: String
	public let name: String
	public let recipes: [Recipe]

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		guard id.isValidQuickLaunchEntryID else {
			throw DecodingError.dataCorruptedError(
				forKey: .id,
				in: container,
				debugDescription: "Identifiers must be non-empty and contain only ASCII letters, digits, and hyphens."
			)
		}
		name = try container.decode(String.self, forKey: .name)
		recipes = try container.decode([Recipe].self, forKey: .recipes)
	}
}
