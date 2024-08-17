//
//  Device.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// Structure representing any kind of device.
public protocol Device {
	/// The unique identifier of the device.
	var id: String { get }

	/// The runtime of the device.
	var runtime: Runtime { get }

	/// The name of the device.
	var name: String { get }

	/// The type of the device.
	var type: DeviceType { get }

	/// The connection by which the device is attached to the system.
	var connection: Connection { get }

	/// The current state of the device.
	var state: DeviceState { get }

	/// Whether the device is locked.
	var isLocked: Bool { get async throws }

	/// Starts the device.
	func boot() async throws

	/// Brings the device to the foreground.
	func focus() throws

	/// Installs an application to the device.
	/// - Parameter application: The application to install..
	func install(application: Application) throws

	/// Launches a given application on the device.
	/// - Parameter application: The application to launch
	func launch(application: Application, arguments: [String]?) throws

	/// Waits until the device has been unlocked.
	func waitUntilUnlocked() async throws

	/// Streams a device to the host machine.
	func stream() throws

	/// Opens the system logs of the device
	func openLogs() throws
}

// The following methods don't apply to all types of devices, so we default to no-op.
public extension Device {
	func boot() async throws {}
	func focus() throws {}
	func stream() throws {}
}

public extension Collection where Element: Device {
	func filter(type: DeviceType) -> [Element] {
		filter { $0.type == type }
	}
}
