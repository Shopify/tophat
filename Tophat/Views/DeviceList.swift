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
	@EnvironmentObject private var deviceManager: DeviceManager
	@CodableAppStorage("PinnedDevices") private var pinnedDeviceIdentifiers: [String] = []
	@State private var otherDevicesExpanded = false

	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Size.menuMargin) {
			if !primaryDevices.isEmpty {
				HStack(alignment: .center) {
					Text("Devices")
						.sectionHeadingTextStyle()

					if deviceManager.isLoading {
						ProgressView()
							.progressViewStyle(.circular)
							.controlSize(.mini)
							.labelsHidden()
					}

					Spacer()
				}
				.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
				.padding(.top, Theme.Size.menuPaddingVertical)

				DevicePicker(devices: primaryDevices)

				Divider()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
			}

			CollapsibleSection("Other Devices", expanded: $otherDevicesExpanded) {
				ScrollView(.vertical, showsIndicators: false) {
					DevicePicker(devices: secondaryDevices)
				}
				.frame(maxHeight: 240)
			}
		}
		.onChange(of: scenePhase) { newValue in
			if newValue == .active {
				Task(priority: .userInitiated) {
					await deviceManager.loadDevices()
				}
			}
		}
	}

	private var supportedDevices: [Device] {
		deviceManager.devices.filter { device in
			[.iOS, .android].contains(device.runtime.platform)
		}
	}

	private var primaryDevices: [Device] {
		supportedDevices.filter { device in
			device.type == .device || pinnedDeviceIdentifiers.contains(device.id)
		}
	}

	private var secondaryDevices: [Device] {
		supportedDevices.filter { device in
			device.type == .simulator && !pinnedDeviceIdentifiers.contains(device.id)
		}
	}
}
