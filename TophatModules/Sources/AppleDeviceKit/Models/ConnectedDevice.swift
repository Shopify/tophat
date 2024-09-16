//
//  ConnectedDevice.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-11.
//  Copyright © 2022 Shopify. All rights reserved.
//

struct ConnectedDevice {
	let interface: Interface
	let deviceIdentifier: String
	let deviceName: String
	let productVersion: String
	let connectionState: ConnectionState

	enum Interface {
		case usb
		case wifi
	}

	enum ConnectionState {
		case connected
		case unavailable
	}
}
