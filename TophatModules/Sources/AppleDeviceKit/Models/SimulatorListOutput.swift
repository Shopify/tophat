//
//  SimulatorListOutput.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

struct SimulatorListOutput: Decodable {
	let devices: [String: [Device]]

	struct Device: Decodable {
		let dataPath: String
		let logPath: String
		let udid: String
		let isAvailable: Bool
		let deviceTypeIdentifier: String
		let state: String
		let name: String
	}
}
