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
	private let connectedDeviceStore: ConnectedDeviceStore

	init(virtualDevice: VirtualDevice, connectedDevice: ConnectedDevice? = nil) {
		self.virtualDevice = virtualDevice
		self.connectedDeviceStore = ConnectedDeviceStore(virtualDevice: virtualDevice, connectedDevice: connectedDevice)
	}
}

private extension ProxyVirtualDevice {
	actor ConnectedDeviceStore {
		private let virtualDevice: VirtualDevice
		private(set) var connectedDevice: ConnectedDevice?

		init(virtualDevice: VirtualDevice, connectedDevice: ConnectedDevice?) {
			self.virtualDevice = virtualDevice
			self.connectedDevice = connectedDevice
		}

		func update(serial: String) {
			self.connectedDevice = Adb.listDevices().first { $0.serial == serial }
		}
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
		.init(platform: .android, version: .exact(virtualDevice.androidVersion))
	}

	var type: DeviceType {
		.simulator
	}

	var connection: Connection {
		.internal
	}

	var state: DeviceState {
		get async {
			await connectedDeviceStore.connectedDevice?.state ?? .unavailable
		}
	}

	var isLocked: Bool {
		false
	}

	func boot() async throws {
		do {
			let serial = try await Emulator.start(name: name)
			try Adb.wait(forSerial: serial)

			await connectedDeviceStore.update(serial: serial)
		} catch {
			throw DiagnosticError(DeviceError.failedToBoot, technicalDetails: error.shellErrorDiagnosticMessage)
		}

		guard await connectedDeviceStore.connectedDevice != nil else {
			throw await DeviceError.deviceNotAvailable(state: state)
		}
	}

	func openLogs() async throws {
		guard let connectedDevice = await connectedDeviceStore.connectedDevice else {
			throw await DeviceError.deviceNotAvailable(state: state)
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

	func install(application: Application) async throws {
		// Equivalent errors thrown by ConnectedDevice
		try await connectedDeviceStore.connectedDevice?.install(application: application)
	}

	func launch(application: Application, arguments: [String]? = nil) async throws {
		// Equivalent errors thrown by ConnectedDevice
		try await connectedDeviceStore.connectedDevice?.launch(application: application, arguments: arguments)
	}

	func stream() async throws {
		do {
			try await connectedDeviceStore.connectedDevice?.stream()
		} catch {
			throw DeviceError.failedToStream
		}
	}

	func waitUntilUnlocked() async throws {
		// Does not apply to Android devices.
	}
}
