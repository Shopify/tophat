//
//  TophatInstallHintedNotification.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

public struct TophatInstallHintedNotification: TophatInterProcessNotification {
	public static let name = "TophatInstallApplicationHinted"

	public struct Payload: Codable {
		public let platform: Platform
		public let virtualURL: URL?
		public let physicalURL: URL?
		public let universalURL: URL?
		public let launchArguments: [String]

		public init(platform: Platform, virtualURL: URL?, physicalURL: URL?, universalURL: URL?, launchArguments: [String]) {
			self.platform = platform
			self.virtualURL = virtualURL
			self.physicalURL = physicalURL
			self.universalURL = universalURL
			self.launchArguments = launchArguments
		}
	}

	public let payload: Payload

	public init(payload: Payload) {
		self.payload = payload
	}
}
