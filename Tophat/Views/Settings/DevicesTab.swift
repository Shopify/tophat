//
//  DevicesTab.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-15.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct DevicesTab: View {
	@Environment(DeviceManager.self) private var deviceManager
	@CodableAppStorage("PinnedDevices") private var pinnedDeviceIdentifiers: [String] = []

	var body: some View {
		Form {
			Section {
				ForEach(pinnableDevices, id: \.id) { device in
					Toggle(isOn: selected(device: device)) {
						VStack(alignment: .leading, spacing: 2) {
							Text(device.name)
								.foregroundColor(.primary)

							Text(String(describing: device.runtime))
								.font(.caption2)
								.foregroundColor(.secondary)
						}
					}
				}
			} header: {
				Text("Pinned Simulators")
				Text("Simulators are shown in a collapsed section by default. Choose which ones should always be visible.")
			}
		}
		.formStyle(.grouped)
	}

	private func selected(device: Device) -> Binding<Bool> {
		Binding {
			pinnedDeviceIdentifiers.contains(device.id)
		} set: { newValue in
			if newValue {
				pinnedDeviceIdentifiers.append(device.id)
			} else {
				pinnedDeviceIdentifiers.removeAll { $0 == device.id }
			}
		}
	}

	private var pinnableDevices: [Device] {
		deviceManager.devices.filter { device in
			device.type == .simulator
		}
	}
}
