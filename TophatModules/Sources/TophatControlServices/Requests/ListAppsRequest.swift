//
//  ListAppsRequset.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

public struct ListAppsRequset: TophatRemoteControlRequest {
	public struct Reply: Codable, Sendable {
		public struct App: Codable, Sendable {
			public let id: String
			public let name: String
			public let platforms: Set<Platform>
			public let recipeCount: Int

			public init(id: String, name: String, platforms: Set<Platform>, recipeCount: Int) {
				self.id = id
				self.name = name
				self.platforms = platforms
				self.recipeCount = recipeCount
			}
		}

		public let apps: [App]

		public init(apps: [App]) {
			self.apps = apps
		}
	}

	public let id: UUID

	public init() {
		self.id = UUID()
	}
}
