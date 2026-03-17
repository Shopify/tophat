//
//  ConnectedDevice.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

struct ConnectedDevice: Sendable {
	let serial: String
	let _state: State
	let usb: String?
	let product: String?
	let model: String?
	let device: String?
	let transportId: String?
	private(set) var androidVersion: String?

	mutating func resolveAndroidVersion() {
		self.androidVersion = try? Adb.getVersion(serial: serial)
	}

	enum State: String, Sendable {
		case device = "device"
		case offline = "offline"
		case noDevice = "no device"
	}
}
