//
//  DevicePicker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct DevicePicker: View {
	@EnvironmentObject private var deviceSelectionManager: DeviceSelectionManager
	@EnvironmentObject private var taskStatusReporter: TaskStatusReporter

	let devices: [Device]

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			ForEach(devices, id: \.id) { device in
				DeviceItem(device: device, selected: selected(device: device), isBusy: isBusy(device: device))
			}
		}
	}

	private func selected(device: Device) -> Binding<Bool> {
		Binding {
			deviceSelectionManager.selectedDevices.contains { $0.id == device.id }
		} set: { newValue in
			didSelect(device: device)
		}
	}

	private func didSelect(device: Device) {
		switch device.runtime.platform {
			case .iOS:
				deviceSelectionManager.selectedAppleDeviceIdentifier = device.id
			case .android:
				deviceSelectionManager.selectedAndroidDeviceIdentifier = device.id
			default:
				break
		}
	}

	private func isBusy(device: Device) -> Bool {
		taskStatusReporter.statuses.contains { status in
			guard let installStatusMetadata = status.metadata as? InstallStatusMetadata else {
				return false
			}

			return installStatusMetadata.deviceId == device.id
		}
	}
}
