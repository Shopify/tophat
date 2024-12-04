//
//  DeviceMenu.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct DeviceMenu: View {
	@Environment(\.prepareDevice) private var prepareDevice
	@Environment(\.mirrorDeviceDisplay) private var mirrorDeviceDisplay
	@CodableAppStorage("PinnedDevices") private var pinnedDeviceIdentifiers: [String] = []

	@State private var deviceState: DeviceState = .unavailable

	let device: Device

	var body: some View {
		Menu {
			if device.type == .simulator {
				Button(deviceState == .ready ? "Running" : "Start") {
					Task {
						await prepareDevice?(device: device)
					}
				}
				.disabled(deviceState == .ready)
			}

			if device.runtime.platform == .android {
				Button("Mirror Display") {
					Task {
						await mirrorDeviceDisplay?(device: device)
					}
				}
				.disabled(deviceState != .ready)
			}

			Button(device.runtime.platform == .android ? "Show Device Logs" : "Open Console…") {
				Task {
					try? await device.openLogs()
				}
			}
			.disabled(deviceState != .ready)

			Divider()

			Button("Copy Name") {
				copy(text: device.name)
			}

			Button("Copy Identifier") {
				copy(text: device.id)
			}

			Divider()

			if device.type == .simulator {
				Button("Reveal Device Window") {
					Task.detached {
						try? device.focus()
					}
				}
				.disabled(deviceState != .ready)

				Divider()

				Button(pinned ? "Unpin" : "Pin") {
					pinned.toggle()
				}
			}
		} label: {
			Image(systemName: "ellipsis.circle")
				.foregroundColor(.secondary)
		}
		.buttonStyle(.plain)
		.task {
			deviceState = await device.state
		}
	}

	private var pinned: Bool {
		get {
			pinnedDeviceIdentifiers.contains(device.id)
		}

		nonmutating set {
			if newValue {
				pinnedDeviceIdentifiers.append(device.id)
			} else {
				pinnedDeviceIdentifiers.removeAll { $0 == device.id }
			}
		}
	}

	private func copy(text: String) {
		let pasteboard = NSPasteboard.general
		pasteboard.declareTypes([.string], owner: nil)
		pasteboard.setString(text, forType: .string)
	}
}
