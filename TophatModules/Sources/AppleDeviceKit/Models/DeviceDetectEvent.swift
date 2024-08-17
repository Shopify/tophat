//
//  DeviceDetectEvent.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-11.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

struct DeviceDetectEvent: Decodable {
	let event: String
	let interface: String
	let device: Device

	enum CodingKeys: String, CodingKey {
		case event = "Event"
		case interface = "Interface"
		case device = "Device"
	}

	struct Device: Decodable {
		let buildVersion: String
		let modelSDK: String
		let deviceIdentifier: String
		let deviceClass: String
		let productType: String
		let deviceName: String
		let productVersion: String
		let modelArch: String
		let hardwareModel: String
		let modelName: String

		enum CodingKeys: String, CodingKey {
			case buildVersion = "BuildVersion"
			case modelSDK = "modelSDK"
			case deviceIdentifier = "DeviceIdentifier"
			case deviceClass = "DeviceClass"
			case productType = "ProductType"
			case deviceName = "DeviceName"
			case productVersion = "ProductVersion"
			case modelArch = "modelArch"
			case hardwareModel = "HardwareModel"
			case modelName = "modelName"
		}
	}
}
