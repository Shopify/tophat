//
//  InstallApplicationTask.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

struct InstallApplicationTask {
	let taskStatusReporter: TaskStatusReporter
	let context: OperationContext?

	func callAsFunction(application: Application, device: Device, launchArguments: [String], deepLink: String? = nil) async throws {
		let metadata = InstallStatusMetadata(deviceId: device.id)
		let appName = application.name ?? context?.applicationDisplayName
		let status = await TaskStatus(
			displayName: "Installing \(appName ?? "App")",
			initialState: .preparing,
			metadata: metadata
		)

		await taskStatusReporter.add(status: status)

		defer {
			Task {
				await status.markAsDone()
			}
		}

		let notificationAppName = appName ?? "application"

		try application.validateEligibility(for: device)
		log.info("Application validated for installation on device")

		log.info("Installing application from local path \(application.url.path(percentEncoded: false))")
		await taskStatusReporter.notify(message: "Installing \(notificationAppName) on \(device.name)…")
		await status.update(state: .running(message: "Installing to \(device.name)"))

		try await device.install(application: application)

		let bundleIdentifier = try application.bundleIdentifier

		if try await device.isLocked {
			await status.update(state: .waiting(reason: .deviceIsLocked))
			try await device.waitUntilUnlocked()
		}

		log.info("Launching application with bundle identifier \(bundleIdentifier)")
		await taskStatusReporter.notify(message: "Launching \(notificationAppName) on \(device.name)…")
		await status.update(state: .running(message: "Launching on \(device.name)"))

		try await device.launch(application: application, arguments: launchArguments, deepLink: deepLink)
	}
}
