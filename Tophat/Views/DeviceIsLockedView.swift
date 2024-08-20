//
//  DeviceIsLockedView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-09-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct DeviceIsLockedView: View {
	@EnvironmentObject private var taskStatusReporter: TaskStatusReporter
	@EnvironmentObject private var deviceManager: DeviceManager

	var body: some View {
		VStack(alignment: .center, spacing: 16) {
            Image(.settingsAppIcon)
				.resizable()
				.interpolation(.high)
				.scaledToFit()
				.frame(width: 64, height: 64)

			VStack(spacing: 10) {
				Text("Unlock \(deviceName ?? "Device") to Continue")
					.font(.headline)
					.foregroundColor(.primary)
					.fixedSize(horizontal: false, vertical: true)
					.multilineTextAlignment(.center)

				Text("Tophat cannot launch the application on \(deviceName ?? "the device") because the device is locked.")
					.font(.subheadline)
					.fixedSize(horizontal: false, vertical: true)
					.multilineTextAlignment(.center)
			}

			ProgressView()
				.progressViewStyle(.circular)
				.controlSize(.small)
				.padding(.vertical, 4)
		}
		.padding(.top, 20)
		.padding(.bottom, 16)
		.padding(.horizontal, 18)
		.frame(maxWidth: 260)
	}

	private var deviceToUnlock: Device? {
		let lockedStatus = taskStatusReporter.statuses.first { status in
			status.state == .waiting(reason: .deviceIsLocked)
		}

		guard let metadata = lockedStatus?.metadata as? InstallStatusMetadata else {
			return nil
		}

		return deviceManager.devices.first { device in
			device.id == metadata.deviceId
		}
	}

	private var deviceName: String? {
		deviceToUnlock?.name
	}
}
