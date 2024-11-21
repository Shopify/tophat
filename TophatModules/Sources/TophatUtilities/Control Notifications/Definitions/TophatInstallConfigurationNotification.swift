//
//  TophatInstallConfigurationNotification.swift
//  TophatUtilities
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct TophatInstallConfigurationNotification: TophatInterProcessNotification {
	public static let name = "TophatInstallConfiguration"

	public struct Payload: Codable {
		public let installRecipes: [UserSpecifiedInstallRecipe]

		public init(installRecipes: [UserSpecifiedInstallRecipe]) {
			self.installRecipes = installRecipes
		}
	}

	public let payload: Payload

	public init(payload: Payload) {
		self.payload = payload
	}
}
