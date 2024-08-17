//
//  TophatRemovePinnedApplicationNotification.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

public struct TophatRemovePinnedApplicationNotification: TophatInterProcessNotification {
	public static let name = "TophatRemovePinnedApplication"

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
