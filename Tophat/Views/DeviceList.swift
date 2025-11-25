//
//  DeviceList.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct DeviceList: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(DeviceManager.self) private var deviceManager

	@CodableAppStorage("PinnedDevices") private var pinnedDeviceIdentifiers: [String] = []

	@State private var isOtherSimulatorsExpanded = false

	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Size.menuItemSpacing) {
			if !devices.isEmpty {
				DevicePickerSection(
					title: "Devices",
					devices: devices,
					isLoading: deviceManager.isLoading
				)

				Divider()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
			}

			if !pinnedSimualators.isEmpty {
				DevicePickerSection(
					title: "Simulators",
					devices: pinnedSimualators,
					isLoading: deviceManager.isLoading && devices.isEmpty
				)

				Divider()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
			}

			CollapsibleSection(
				pinnedSimualators.isEmpty ? "Simulators" : "Other Simulators",
				expanded: $isOtherSimulatorsExpanded
			) {
				ScrollView(.vertical, showsIndicators: false) {
					DevicePicker(devices: otherSimulators)
				}
				.frame(maxHeight: 240)
			}
		}
		.onChange(of: scenePhase) { oldValue, newValue in
			if newValue == .active {
				Task(priority: .userInitiated) {
					await deviceManager.loadDevices()
				}
			}
		}
	}

	private var devices: [Device] {
		deviceManager.devices.filter { device in
			device.type == .device
		}
	}

	private var pinnedSimualators: [Device] {
		deviceManager.devices.filter { device in
			device.type == .simulator && pinnedDeviceIdentifiers.contains(device.id)
		}
	}

	private var otherSimulators: [Device] {
		deviceManager.devices.filter { device in
			device.type == .simulator && !pinnedDeviceIdentifiers.contains(device.id)
		}
	}
}
