//
//  TophatAddPinnedApplicationNotification.swift
//  TophatUtilities
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

public struct TophatAddPinnedApplicationNotification: TophatInterProcessNotification {
	public static let name = "TophatAddPinnedApplication"

	public struct Payload: Codable {
		public let configuration: UserSpecifiedQuickLaunchEntryConfiguration

		public init(configuration: UserSpecifiedQuickLaunchEntryConfiguration) {
			self.configuration = configuration
		}
	}

	public let payload: Payload

	public init(payload: Payload) {
		self.payload = payload
	}
}
