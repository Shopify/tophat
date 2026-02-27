//
//  InstallFromRecipesRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct InstallFromRecipesRequest: TophatRemoteControlRequest {
	public typealias Reply = InstallationRequestReply

	public let id: UUID
	public let recipes: [UserSpecifiedRecipeConfiguration]
	public let deviceIdentifier: String?

	public init(recipes: [UserSpecifiedRecipeConfiguration], deviceIdentifier: String? = nil) {
		self.id = UUID()
		self.recipes = recipes
		self.deviceIdentifier = deviceIdentifier
	}
}
