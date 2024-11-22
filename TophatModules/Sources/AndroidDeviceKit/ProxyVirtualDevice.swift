//
//  ProxyVirtualDevice.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2023-01-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

/// A container class that can track the connected device associated with a simulator device
/// on the fly.
final class ProxyVirtualDevice {
	private let virtualDevice: VirtualDevice
	private var connectedDevice: ConnectedDevice?

	init(virtualDevice: VirtualDevice, connectedDevice: ConnectedDevice? = nil) {
		self.virtualDevice = virtualDevice
		self.connectedDevice = connectedDevice
	}

	private func updateConnectedDevice() async {
		let connectedDevices = Adb.listDevices()
		let virtualDeviceNameMappings = await connectedDevices.mappedToVirtualDeviceNames()
		self.connectedDevice = virtualDeviceNameMappings.connectedDevice(for: virtualDevice)
	}
}

extension ProxyVirtualDevice: Device {
	var id: String {
		// Because ADB serials aren't always available, we'll always reference simulator devices by name to have a stable value.
		virtualDevice.name
	}

	var name: String {
		virtualDevice.name
	}

	var runtime: Runtime {
		let parsedVersion = virtualDevice.androidVersion.replacingOccurrences(of: "Android ", with: "")
		return .init(platform: .android, version: .exact(parsedVersion))
	}

	var type: DeviceType {
		.simulator
	}

	var connection: Connection {
		.internal
	}

	var state: DeviceState {
		connectedDevice?.state ?? .unavailable
	}

	var isLocked: Bool {
		false
	}

	func boot() async throws {
		do {
			try Emulator.start(name: name)
		} catch {
			throw DeviceError.failedToBoot
		}

		await updateConnectedDevice()

		guard let connectedDevice = connectedDevice else {
			throw DeviceError.deviceNotAvailable(state: state)
		}

		do {
			try Adb.wait(for: connectedDevice)
		} catch {
			throw DeviceError.failedToBoot
		}
	}

	func openLogs() throws {
		guard let connectedDevice = connectedDevice else {
			throw DeviceError.deviceNotAvailable(state: state)
		}

		return try connectedDevice.openLogs()
	}

	func focus() throws {
		let script = "tell application \"System Events\" to set frontmost of first application process whose name starts with \"qemu-system-\" to true"

		guard let script = NSAppleScript(source: script) else {
			throw DeviceError.failedToFocus
		}

		var error: NSDictionary?
		script.executeAndReturnError(&error)

		if error != nil {
			throw DeviceError.failedToFocus
		}
	}

	func install(application: Application) throws {
		// Equivalent errors thrown by ConnectedDevice
		try connectedDevice?.install(application: application)
	}

	func launch(application: Application, arguments: [String]? = nil) throws {
		// Equivalent errors thrown by ConnectedDevice
		try connectedDevice?.launch(application: application, arguments: arguments)
	}

	func stream() throws {
		do {
			try connectedDevice?.stream()
		} catch {
			throw DeviceError.failedToStream
		}
	}

	func waitUntilUnlocked() async throws {
		// Does not apply to Android devices.
	}
}
