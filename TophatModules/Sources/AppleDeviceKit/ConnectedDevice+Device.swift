//
//  ConnectedDevice+Device.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-11.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension ConnectedDevice: Device {
	var id: String {
		deviceIdentifier
	}

	var name: String {
		deviceName
	}

	var runtime: Runtime {
		let platform: Platform = switch platformName {
			case "iOS": .iOS
			case "watchOS": .watchOS
			case "tvOS": .tvOS
			case "visionOS": .visionOS
			default: .unknown
		}

		return Runtime(platform: platform, version: .exact(productVersion))
	}

	var type: DeviceType {
		.device
	}

	var connection: Connection {
		switch interface {
			case .usb:
				return .direct
			case .wifi:
				return .network
		}
	}

	var state: DeviceState {
		connectionState == .connected ? .ready : .unavailable
	}

	var isLocked: Bool {
		get async throws {
			try await DeviceCtl.isLocked(udid: id)
		}
	}

	func install(application: Application) throws {
		do {
			try DeviceCtl.install(udid: id, bundleUrl: application.url)
		} catch {
			throw DeviceError.failedToInstallApp(bundleUrl: application.url, deviceType: type)
		}
	}

	func launch(application: Application, arguments: [String]? = nil) throws {
		do {
			try DeviceCtl.launch(udid: id, bundleId: application.bundleIdentifier, arguments: arguments ?? [])
		} catch {
			let bundleIdentifier = try application.bundleIdentifier
			throw DeviceError.failedToLaunchApp(
				bundleId: bundleIdentifier,
				reason: launchFailureReason(error: error),
				deviceType: type
			)
		}
	}

	func waitUntilUnlocked() async throws {
		log?.info("Waiting for the device to be unlocked")

		try await withThrowingTaskGroup(of: Void.self) { group in
			group.addTask {
				while try await isLocked {
					log?.info("Waiting for device to be unlocked for another 1.5 seconds")
					try await Task.sleep(for: .seconds(1.5))
				}
			}

			group.addTask {
				try await Task.sleep(for: .seconds(300))
				throw DeviceError.deviceUnlockTimedOut
			}

			if try await group.next() != nil {
				group.cancelAll()
				log?.info("The device was unlocked")
			}
		}
	}

	private func launchFailureReason(error: Error) -> DeviceError.FailedToLaunchAppReason {
		if let error = error as? DeviceCtlError, case .requiresManualProfileTrust = error {
			return .requiresManualProfileTrust
		} else {
			return .unexpected
		}
	}
}

extension Device {
	func openLogs() throws {
		let appleScript = "tell application \"Console\" to activate"
		guard let script = NSAppleScript(source: appleScript) else {
			throw DeviceError.failedToOpenLogs
		}

		var error: NSDictionary?
		script.executeAndReturnError(&error)

		if error != nil {
			throw DeviceError.failedToOpenLogs
		}
	}
}
