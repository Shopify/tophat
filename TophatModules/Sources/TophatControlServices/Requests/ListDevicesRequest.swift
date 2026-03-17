//
//  ListDevicesRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2026-03-13.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

public struct ListDevicesRequest: TophatRemoteControlRequest {
	public struct Reply: Codable, Sendable {
		public struct Device: Codable, Sendable {
			public let name: String
			public let type: DeviceType
			public let platform: Platform
			public let runtimeVersion: RuntimeVersion
			public let connection: Connection
			public let state: DeviceState

			public init(name: String, type: DeviceType, platform: Platform, runtimeVersion: RuntimeVersion, connection: Connection, state: DeviceState) {
				self.name = name
				self.type = type
				self.platform = platform
				self.runtimeVersion = runtimeVersion
				self.connection = connection
				self.state = state
			}
		}

		public let devices: [Device]

		public init(devices: [Device]) {
			self.devices = devices
		}
	}

	public let id: UUID

	public init() {
		self.id = UUID()
	}
}
