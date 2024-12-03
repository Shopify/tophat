//
//  VirtualDevice.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

struct VirtualDevice: Sendable {
	let name: String
	let device: String
	let path: String
	let target: String
	let androidVersion: String
	let abi: String
	let skin: String?
	let sdCard: String?
	let snapshot: Bool?
}
