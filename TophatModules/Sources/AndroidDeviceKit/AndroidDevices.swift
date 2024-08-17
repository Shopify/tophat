//
//  AndroidDevices.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import TophatFoundation

/// Utility for retrieving Android devices.
public struct AndroidDevices: DeviceProvider {
	/// A collection of all devices.
	public static var all: [Device] {
		get async {
			async let futureConnectedDevices = Adb.listDevices()
			async let futureVirtualDevices = AvdManager.listVirtualDevices()

			// Loaded concurrently to resolve the list faster.
			let (connectedDevices, virtualDevices) = await (futureConnectedDevices, futureVirtualDevices)

			// Loaded in advance so that we don't re-query adb more than necessary.
			let virtualDeviceNameMappings = await connectedDevices.mappedToVirtualDeviceNames()

			let proxyVirtualDevices = virtualDevices.map { virtualDevice in
				ProxyVirtualDevice(
					virtualDevice: virtualDevice,
					connectedDevice: virtualDeviceNameMappings.connectedDevice(for: virtualDevice)
				)
			}

			// We only care about physical connected devices because adb and avdmanager overlap.
			// avdmanager takes care of returning all virtual devices.
			let physicalDevices = connectedDevices.filter(type: .physical)

			return physicalDevices + proxyVirtualDevices
		}
	}
}
