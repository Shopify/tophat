//
//  TophatRemoveQuickLaunchEntryNotification.swift
//  TophatUtilities
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

public struct TophatRemoveQuickLaunchEntryNotification: TophatInterProcessNotification {
	public static let name = "TophatRemoveQuickLaunchEntry"

	public struct Payload: Codable {
		public let id: String

		public init(id: String) {
			self.id = id
		}
	}

	public let payload: Payload

	public init(payload: Payload) {
		self.payload = payload
	}
}
