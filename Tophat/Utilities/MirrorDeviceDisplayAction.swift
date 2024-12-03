//
//  MirrorDeviceDisplayAction.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-24.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct MirrorDeviceDisplayAction {
	private let taskStatusReporter: TaskStatusReporter

	init(taskStatusReporter: TaskStatusReporter) {
		self.taskStatusReporter = taskStatusReporter
	}

	func callAsFunction(device: Device) async {
		let mirrorDeviceDisplay = MirrorDeviceDisplayTask(taskStatusReporter: taskStatusReporter)

		do {
			try await mirrorDeviceDisplay(device: device)
		} catch {
			ErrorNotifier().notify(error: error)
		}
	}
}

extension EnvironmentValues {
	@Entry var mirrorDeviceDisplay: MirrorDeviceDisplayAction?
}
