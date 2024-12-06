//
//  DeviceListOutput.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2023-07-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

struct DeviceListOutput: Decodable {
	let result: Result

	struct Result: Decodable {
		let devices: [Device]

		struct Device: Decodable {
			let connectionProperties: ConnectionProperties
			let deviceProperties: DeviceProperties
			let hardwareProperties: HardwareProperties
			let identifier: String

			struct ConnectionProperties: Decodable {
				let transportType: String?
			}

			struct DeviceProperties: Decodable {
				let name: String
				let osVersionNumber: String
			}

			struct HardwareProperties: Decodable {
				let udid: String
				let platform: String
			}
		}
	}
}
