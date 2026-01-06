//
//  AppleDevices.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

/// Utility for retrieving iOS devices.
public struct AppleDevices: DeviceProvider {
	/// A collection of all devices.
	public static var all: [Device] {
		get async {
			return await withTaskGroup(of: [Device].self) { group in
				var devices: [Device] = []

				group.addTask {
					let devicesByIdentifier = Dictionary(grouping: await physicalDevices, by: { $0.id })

					let devicesWithFastestConnections = devicesByIdentifier.compactMap { _, devices in
						devices.first { $0.connection == .direct } ?? devices.first { $0.connection == .network }
					}

					return devicesWithFastestConnections.sorted { $0.name > $1.name }
				}

				group.addTask {
					let virtualDevices = try? SimCtl.listAvailableDevices()
					return virtualDevices ?? []
				}

				for await deviceSubset in group {
					devices.append(contentsOf: deviceSubset)
				}

				return devices
			}
		}
	}

	private static var physicalDevices: [ConnectedDevice] {
		get async {
			(try? DeviceCtl.listAvailableDevices()) ?? []
		}
	}
}
