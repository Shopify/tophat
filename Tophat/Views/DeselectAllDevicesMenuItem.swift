//
//  DeselectAllDevicesMenuItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI

struct DeselectAllDevicesMenuItem: View {
	@EnvironmentObject private var deviceSelectionManager: DeviceSelectionManager

	var body: some View {
		Button {
			deviceSelectionManager.selectedDevices.removeAll()
		} label: {
			HStack {
				Text("Deselect All")
				Spacer()
				if !deviceSelectionManager.selectedDevices.isEmpty {
					Text("\(deviceSelectionManager.selectedDevices.count) Selected")
						.foregroundStyle(.tertiary)
						.monospacedDigit()
				}
			}
		}
		.buttonStyle(.menuItem(blinks: true, disabled: deviceSelectionManager.selectedDevices.isEmpty))
	}
}
