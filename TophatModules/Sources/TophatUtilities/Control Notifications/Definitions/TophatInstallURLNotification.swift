//
//  TophatInstallURLNotification.swift
//  TophatUtilities
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

public struct TophatInstallURLNotification: TophatInterProcessNotification {
	public static let name = "TophatInstallApplicationGeneric"

	public struct Payload: Codable {
		public let url: URL
		public let launchArguments: [String]

		public init(url: URL, launchArguments: [String]) {
			self.url = url
			self.launchArguments = launchArguments
		}
	}

	public let payload: Payload

	public init(payload: Payload) {
		self.payload = payload
	}
}
