//
//  ConnectedDevice.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-11.
//  Copyright © 2022 Shopify. All rights reserved.
//

struct ConnectedDevice: Sendable {
	let interface: Interface
	let deviceIdentifier: String
	let deviceName: String
	let productVersion: String
	let connectionState: ConnectionState

	enum Interface: Sendable {
		case usb
		case wifi
	}

	enum ConnectionState: Sendable {
		case connected
		case unavailable
	}
}
