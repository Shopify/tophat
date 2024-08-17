//
//  VirtualDeviceNameMapping.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2023-01-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

struct VirtualDeviceNameMapping {
	let connectedDevice: ConnectedDevice
	let virtualDeviceName: String?
}

extension Collection where Element == VirtualDeviceNameMapping {
	func connectedDevice(for virtualDevice: VirtualDevice) -> ConnectedDevice? {
		first { $0.virtualDeviceName == virtualDevice.name }?.connectedDevice
	}
}

extension Collection where Element == ConnectedDevice {
	/// Returns a collection of containers that map connected devices to their associated virtual device names.
	///
	/// This is an expensive operation as `adb` needs to be called once for each connected device. The
	/// result of this function should be cached as early as possible so that these values are only resolved
	/// once. Only virtual devices are queried, physical devices are ignored and are not returned.
	/// - Returns: A collection of containers including the connected device and its associated virtual
	/// device name.
	func mappedToVirtualDeviceNames() async -> [VirtualDeviceNameMapping] {
		return await withTaskGroup(of: VirtualDeviceNameMapping.self, returning: [VirtualDeviceNameMapping].self) { group in
			filter(type: .virtual).forEach { connectedVirtualDevice in
				group.addTask {
					return VirtualDeviceNameMapping(
						connectedDevice: connectedVirtualDevice,
						virtualDeviceName: connectedVirtualDevice.virtualDeviceName
					)
				}
			}

			var items: [VirtualDeviceNameMapping] = []

			for await item in group {
				items.append(item)
			}

			return items
		}
	}
}

private extension ConnectedDevice {
	var virtualDeviceName: String? {
		return try? Adb.getVirtualDeviceName(for: self)
	}
}
