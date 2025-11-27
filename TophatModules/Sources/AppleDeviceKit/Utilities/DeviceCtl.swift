//
//  DeviceCtl.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2023-07-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ShellKit

final class DeviceCtl {
	static func listAvailableDevices() throws -> [ConnectedDevice] {
		let outputURL = temporaryOutputURL()
		try run(command: .deviceCtl(.list(outputUrl: outputURL)), log: log)

		let data = try Data(contentsOf: outputURL)
		let output = try JSONDecoder().decode(DeviceListOutput.self, from: data)

		try FileManager.default.removeItem(at: outputURL)

		return output.result.devices.map { .init(from: $0 ) }.filter { $0.state == .ready }
	}

	static func install(udid: String, bundleUrl: URL) throws {
		try run(command: .deviceCtl(.install(device: udid, bundleUrl: bundleUrl)), log: log)
	}

	static func launch(udid: String, bundleId: String, arguments: [String]) throws {
		let outputURL = temporaryOutputURL()

		do {
			try run(command: .deviceCtl(.launch(device: udid, bundleId: bundleId, outputUrl: outputURL, arguments: arguments)), log: log)
		} catch let error {
			if let output = try? String(contentsOf: outputURL),
			   output.contains("profile has not been explicitly trusted by the user") {
				throw DeviceCtlError.requiresManualProfileTrust
			} else {
				throw error
			}
		}
	}

	static func openURL(udid: String, url: String) throws {
		try run(command: .deviceCtl(.openURL(device: udid, url: url.wrappedInQuotationMarks())), log: log)
	}

	static nonisolated func isLocked(udid: String) async throws -> Bool {
		let outputURL = temporaryOutputURL()
		try run(command: .deviceCtl(.lockState(device: udid, outputURL: outputURL)), log: log)

		let data = try Data(contentsOf: outputURL)
		let output = try JSONDecoder().decode(DeviceLockStateOutput.self, from: data)

		try FileManager.default.removeItem(at: outputURL)

		return output.result.passcodeRequired
	}

	private static func temporaryOutputURL() -> URL {
		.temporaryDirectory.appending(path: UUID().uuidString)
	}
}

enum DeviceCtlError: Error {
	case requiresManualProfileTrust
}

private extension ConnectedDevice {
	init(from deviceListDevice: DeviceListOutput.Result.Device) {
		self.interface = .init(from: deviceListDevice.connectionProperties.transportType)
		self.connectionState = deviceListDevice.connectionProperties.transportType == nil ? .unavailable : .connected

		self.deviceIdentifier = deviceListDevice.hardwareProperties.udid
		self.platformName = deviceListDevice.hardwareProperties.platform
		self.deviceName = deviceListDevice.deviceProperties.name
		self.productVersion = deviceListDevice.deviceProperties.osVersionNumber
	}
}

private extension ConnectedDevice.Interface {
	init(from transportTypeString: String?) {
		switch transportTypeString {
			case "localNetwork":
				self = .wifi
			default:
				self = .usb
		}
	}
}
