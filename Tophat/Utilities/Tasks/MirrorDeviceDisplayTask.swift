//
//  MirrorDeviceDisplayTask.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

import TophatFoundation

struct MirrorDeviceDisplayTask {
	let taskStatusReporter: TaskStatusReporter

	func callAsFunction(device: Device) async throws {
		let status = await TaskStatus(displayName: "Mirroring \(device.name)", initialState: .running(message: "Connecting"))
		await taskStatusReporter.add(status: status)

		defer {
			Task {
				await status.markAsDone()
			}
		}

		try await device.stream()
	}
}
