//
//  DeviceProvider.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-28.
//  Copyright © 2022 Shopify. All rights reserved.
//

public protocol DeviceProvider {
	/// A collection of all devices.
	static var all: [Device] { get async }
}
