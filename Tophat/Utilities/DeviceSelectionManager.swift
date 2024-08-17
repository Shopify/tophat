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
final class DeviceSelectionManager: ObservableObject {
	private unowned let deviceManager: DeviceManager

	// Setting a default value as Picker does not handle optionals reliably.
	@AppStorage("SelectedAppleDevice") var selectedAppleDeviceIdentifier: String = ""
	@AppStorage("SelectedAndroidDevice") var selectedAndroidDeviceIdentifier: String = ""

	init(deviceManager: DeviceManager) {
		self.deviceManager = deviceManager

		// Configure default devices if none were initially selected.
		if selectedAppleDeviceIdentifier.isEmpty,
		   let firstAppleDevice = devices.filter(by: .iOS).first {
			selectedAppleDeviceIdentifier = firstAppleDevice.id
		}

		if selectedAndroidDeviceIdentifier.isEmpty,
		   let firstAndroidDevice = devices.filter(by: .android).first {
			selectedAndroidDeviceIdentifier = firstAndroidDevice.id
		}
	}

	var selectedAppleDevice: Device? {
		devices.first { $0.id == selectedAppleDeviceIdentifier }
	}

	var selectedAndroidDevice: Device? {
		devices.first { $0.id == selectedAndroidDeviceIdentifier }
	}

	/// A collection of all currently selected devices.
	var selectedDevices: [Device] {
		[selectedAppleDevice, selectedAndroidDevice].compactMap { $0 }
	}

	private var devices: [Device] {
		deviceManager.devices
	}
}
