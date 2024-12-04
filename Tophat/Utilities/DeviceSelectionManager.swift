//
//  DeviceSelectionManager.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-28.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import SwiftUI

/// Manages the user's selection of devices to install builds to.
@MainActor final class DeviceSelectionManager: ObservableObject {
	private unowned let deviceManager: DeviceManager

	@CodableAppStorage("SelectedDeviceIdentifiers") var selectedDeviceIdentifiers: [String] = []

	init(deviceManager: DeviceManager) {
		self.deviceManager = deviceManager

		// Configure default devices if none were initially selected.
		if selectedDeviceIdentifiers.isEmpty {
			for platform in Platform.allCases {
				if let firstPlatformDevice = devices.filter(by: platform).first {
					selectedDeviceIdentifiers.append(firstPlatformDevice.id)
				}
			}
		}
	}

	/// A collection of all currently selected devices.
	var selectedDevices: [Device] {
		get {
			devices.filter { selectedDeviceIdentifiers.contains($0.id) }
		}
		set {
			selectedDeviceIdentifiers = newValue.map { $0.id }
			objectWillChange.send()
		}
	}

	private var devices: [Device] {
		deviceManager.devices
	}
}
