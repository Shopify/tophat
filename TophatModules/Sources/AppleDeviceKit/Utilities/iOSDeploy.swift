//
//  iOSDeploy.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2020-11-11.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

final class iOSDeploy {
	static func listAvailableDevices() async -> [ConnectedDevice] {
		var devices: [ConnectedDevice] = []

		do {
			for try await output in runAsync(command: .iOSDeploy(.list), log: log) {
				guard
					case .standardOutput(let line) = output,
					let data = line.data(using: .utf8),
					let event = try? JSONDecoder().decode(DeviceDetectEvent.self, from: data)
				else {
					continue
				}

				devices.append(.init(from: event))
			}
		} catch {
			log?.warning("ios-deploy encountered an error and has returned \(devices.count) devices")
			// ios-deploy may return with error 253 when no devices are returned but this is expected.
			// ios-deploy may also throw an error even when some devices have been returned.
			return devices
		}

		return devices
	}

	static func install(udid: String, bundleUrl: URL, noWifi: Bool) throws {
		try run(command: .iOSDeploy(.install(device: udid, bundleUrl: bundleUrl, noWifi: noWifi)), log: log)
	}

	static func launch(udid: String, bundleId: String, noWifi: Bool) throws {
		try run(command: .iOSDeploy(.launch(device: udid, bundleId: bundleId, noWifi: noWifi)), log: log)
	}
}

private extension ConnectedDevice {
	init(from deviceDetectEvent: DeviceDetectEvent) {
		self.interface = .init(from: deviceDetectEvent.interface)

		let device = deviceDetectEvent.device

		self.deviceIdentifier = device.deviceIdentifier
		self.deviceName = device.deviceName
		self.productVersion = device.productVersion
		self.connectionState = .connected
	}
}

private extension ConnectedDevice.Interface {
	init(from string: String) {
		switch string {
			case "WIFI":
				self = .wifi
			default:
				self = .usb
		}
	}
}
