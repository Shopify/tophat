//
//  PrepareDeviceTask.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import TophatFoundation

struct PrepareDeviceTask {
	struct Result {
		let deviceWasColdBooted: Bool
	}

	private let taskStatusReporter: TaskStatusReporter

	init(taskStatusReporter: TaskStatusReporter) {
		self.taskStatusReporter = taskStatusReporter
	}

	@discardableResult
	func callAsFunction(device: Device) async throws -> Result {
		guard device.state != .ready else {
			return Result(deviceWasColdBooted: false)
		}

		let metadata = InstallStatusMetadata(deviceId: device.id)
		let status = TaskStatus(displayName: "Starting \(device.name)", initialState: .running(message: "Booting"), metadata: metadata)
		await taskStatusReporter.add(status: status)

		defer {
			Task {
				await status.markAsDone()
			}
		}

		log.info("The device \(device.id) is not ready. Attempting to boot device")
		taskStatusReporter.notify(message: "Starting device \(device.name)…")

		try await device.boot()

		return Result(deviceWasColdBooted: true)
	}
}
