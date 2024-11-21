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

	let device: Device

	var body: some View {
		Menu {
			if device.type == .simulator {
				Button(device.state == .ready ? "Running" : "Start") {
					Task {
						await prepareDevice?(device: device)
					}
				}
				.disabled(device.state == .ready)
			}

			if device.runtime.platform == .android {
				Button("Mirror Display") {
					Task {
						await mirrorDeviceDisplay?(device: device)
					}
				}
				.disabled(device.state != .ready)
			}

			Button(device.runtime.platform == .android ? "Show Device Logs" : "Open Console…") {
				Task.detached {
					try? device.openLogs()
				}
			}
			.disabled(device.state != .ready)

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
				.disabled(device.state != .ready)

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
