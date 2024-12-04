//
//  ListProvidersRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct ListProvidersRequest: TophatRemoteControlRequest {
	public struct Reply: Codable, Sendable {
		public struct Provider: Codable, Sendable {
			public struct Parameter: Codable, Sendable {
				public let key: String
				public let title: String

				public init(key: String, title: String) {
					self.key = key
					self.title = title
				}
			}

			public let id: String
			public let title: String
			public let extensionTitle: String
			public let parameters: [Parameter]

			public init(id: String, title: String, extensionTitle: String, parameters: [Parameter]) {
				self.id = id
				self.title = title
				self.extensionTitle = extensionTitle
				self.parameters = parameters
			}
		}

		public let providers: [Provider]

		public init(providers: [Provider]) {
			self.providers = providers
		}
	}

	public let id: UUID

	public init() {
		self.id = UUID()
	}
}
