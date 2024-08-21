//
//  DeviceItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-12.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct DeviceItem: View {
	let device: Device
	@Binding var selected: Bool
	let isBusy: Bool

	var body: some View {
		ToggleableRow(action: { selected = true }) {
			HStack(spacing: 6) {
				VStack(alignment: .leading, spacing: 2) {
					Text(device.name)
						.foregroundColor(.primary)

					Text(String(describing: device.runtime))
						.font(.caption2)
						.opacity(0.8)
						.foregroundColor(.secondary)
				}

				Spacer()

				if isBusy {
					ProgressView()
						.progressViewStyle(.circular)
						.controlSize(.small)
				}

				if let iconName = connectionIconName {
					Image(systemName: iconName)
						.foregroundColor(.secondary)
				}

				DeviceMenu(device: device)
					.visibleWhenButtonHovered()
			}
			.padding(.trailing, 6)

		} icon: {
			ToggleableRowIcon(selected: selected) {
				if device.runtime.platform == .android {
					Image(.androidFill)
						.resizable()
						.scaledToFit()
						.frame(maxWidth: 14)
				} else {
					Image(systemName: device.name.contains("iPad") ? "ipad" : "iphone")
				}
			}
		}
	}

	private var connectionIconName: String? {
		switch device.connection {
			case .direct:
				return "cable.connector.horizontal"
			case .network:
				return "wifi"
			default:
				return nil
		}
	}
}
