//
//  DeviceIsLockedViewModifier.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-09-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct DeviceIsLockedViewModifier: ViewModifier {
	@EnvironmentObject private var taskStatusReporter: TaskStatusReporter
	@EnvironmentObject private var deviceManager: DeviceManager

	func body(content: Content) -> some View {
		content
			.floatingPanel(isPresented: .constant(isWaitingForDeviceUnlock), isPersistent: true) {
				DeviceIsLockedView()
					.environmentObject(taskStatusReporter)
					.environmentObject(deviceManager)
			}
	}

	private var isWaitingForDeviceUnlock: Bool {
		taskStatusReporter.statuses.contains { status in
			status.state == .waiting(reason: .deviceIsLocked)
		}
	}
}
