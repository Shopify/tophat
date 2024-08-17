//
//  TophatAddPinnedApplicationNotification.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

public struct TophatAddPinnedApplicationNotification: TophatInterProcessNotification {
	public static let name = "TophatAddPinnedApplication"

	public struct Payload: Codable {
		public let id: String?
		public let name: String
		public let platform: Platform
		public let virtualURL: URL?
		public let physicalURL: URL?
		public let universalURL: URL?
		public let artifactProviderURL: URL?

		public init(
			id: String? = nil,
			name: String,
			platform: Platform,
			virtualURL: URL?,
			physicalURL: URL?,
			universalURL: URL?,
			artifactProviderURL: URL?
		) {
			self.id = id
			self.name = name
			self.platform = platform
			self.virtualURL = virtualURL
			self.physicalURL = physicalURL
			self.universalURL = universalURL
			self.artifactProviderURL = artifactProviderURL
		}
	}

	public let payload: Payload

	public init(payload: Payload) {
		self.payload = payload
	}
}
