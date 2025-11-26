//
//  ConnectedDevice+Device.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension ConnectedDevice: Device {
	var id: String {
		serial
	}

	var runtime: Runtime {
		// We aren't yet fetching the version for ADB devices.
		.init(platform: .android, version: .unknown)
	}

	var name: String {
		model?.replacingOccurrences(of: "_", with: " ") ?? serial
	}

	var type: DeviceType {
		guard let product = product else {
			// In case the product name is not available, fall back to checking the serial.
			return serial.contains("emulator") ? .simulator : .device
		}

		return product.contains("sdk_gphone") ? .simulator : .device
	}

	var connection: Connection {
		if usb != nil {
			return .direct
		}

		let adbServiceIndex = try! Regex("_.+\\._tcp")

		// mDNS connections
		if serial.contains(adbServiceIndex) {
			return .network
		}

		// These expressions are very lenient, do not use to check validity.
		let ipv4Address = try! Regex("(?:[0-9]{1,3}\\.){3}[0-9]{1,3}")
		let ipv6Address = try! Regex("(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}")

		// TCP/UDP connections
		if serial.contains(ipv4Address) || serial.contains(ipv6Address) {
			return .network
		}

		return .internal
	}

	var state: DeviceState {
		DeviceState(from: _state)
	}

	var isLocked: Bool {
		false
	}

	func install(application: Application) throws {
		do {
			try Adb.install(serial: id, apkUrl: application.url)
		} catch {
			throw DeviceError.failedToInstallApp(bundleUrl: application.url, deviceType: type)
		}
	}

	func launch(application: Application, arguments: [String]? = nil, deepLink: String? = nil) throws {
		let bundleIdentifier = try application.bundleIdentifier

		do {
			if let deepLink = deepLink {
				// Use deep link to launch the app
				try Adb.deepLink(serial: id, deepLink: deepLink)
			} else {
				// Use regular component launch
				let componentName = try Adb.resolveActivity(serial: id, packageName: bundleIdentifier)
				try Adb.launch(serial: id, componentName: componentName, arguments: arguments ?? [])
			}
		} catch {
			throw DeviceError.failedToLaunchApp(bundleId: bundleIdentifier, reason: .unexpected, deviceType: type)
		}
	}

	func stream() throws {
		try Scrcpy.connect(serial: id)
	}

	func openLogs() throws {
		let appleScript = """
			tell application "Terminal"
				activate
				do script "\(PathResolver.adb.path(percentEncoded: false)) -s \(serial) logcat -v long -v color time"
			end tell
		"""
		guard let script = NSAppleScript(source: appleScript) else {
			throw DeviceError.failedToOpenLogs
		}

		var error: NSDictionary?
		script.executeAndReturnError(&error)

		if error != nil {
			throw DeviceError.failedToOpenLogs
		}
	}

	func waitUntilUnlocked() async throws {
		// Does not apply to Android devices.
	}
}

private extension DeviceState {
	init(from connectedDeviceState: ConnectedDevice.State) {
		switch connectedDeviceState {
			case .device:
				self = .ready
			default:
				self = .unavailable
		}
	}
}
