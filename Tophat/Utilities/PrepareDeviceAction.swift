//
//  PrepareDeviceAction.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-24.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct PrepareDeviceAction {
	private let taskStatusReporter: TaskStatusReporter

	init(taskStatusReporter: TaskStatusReporter) {
		self.taskStatusReporter = taskStatusReporter
	}

	func callAsFunction(device: Device) async {
		let prepareDevice = PrepareDeviceTask(taskStatusReporter: taskStatusReporter)

		do {
			try await prepareDevice(device: device)
		} catch {
			ErrorNotifier().notify(error: error)
		}
	}
}

private struct PrepareDeviceKey: EnvironmentKey {
	static var defaultValue: PrepareDeviceAction?
}

extension EnvironmentValues {
	var prepareDevice: PrepareDeviceAction? {
		get { self[PrepareDeviceKey.self] }
		set { self[PrepareDeviceKey.self] = newValue }
	}
}
