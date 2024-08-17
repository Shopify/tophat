//
//  Simulator+Device.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import RegexBuilder
import ShellKit

extension Simulator: Device {
	var id: String {
		udid
	}

	var runtime: Runtime {
		.init(from: runtimeIdentifier)
	}

	var type: DeviceType {
		.virtual
	}

	var connection: Connection {
		.internal
	}

	var state: DeviceState {
		DeviceState(from: rawState)
	}

	var isLocked: Bool {
		// Simulators do not lock.
		false
	}

	func boot() async throws {
		do {
			try SimCtl.start(udid: id)
			try focus()
		} catch {
			throw DeviceError.failedToBoot
		}
	}

	func focus() throws {
		do {
			try run(command: .open(.simulator), log: log)
		} catch {
			throw DeviceError.failedToFocus
		}
	}

	func install(application: Application) throws {
		do {
			try SimCtl.install(udid: id, bundleUrl: application.url)
		} catch {
			throw DeviceError.failedToInstallApp(bundleUrl: application.url, deviceType: .virtual)
		}
	}

	func launch(application: Application, arguments: [String]? = nil) throws {
		let bundleIdentifier = try application.bundleIdentifier

		do {
			try SimCtl.launch(udid: id, bundleIdentifier: bundleIdentifier, arguments: arguments ?? [])
		} catch {
			throw DeviceError.failedToLaunchApp(bundleId: bundleIdentifier, reason: .unexpected, deviceType: .virtual)
		}
	}

	func waitUntilUnlocked() async throws {
		// Simulators do not lock.
	}
}

private extension Runtime {
	private static let search = Regex {
		"com.apple.CoreSimulator.SimRuntime."
		TryCapture {
			ChoiceOf {
				"iOS"
				"watchOS"
				"tvOS"
			}
		} transform: { substring in
			String(substring)
		}
		"-"
		TryCapture {
			OneOrMore(.any)
		} transform: { substring in
			substring.replacingOccurrences(of: "-", with: ".")
		}
	}

	init(from runtimeIdentifier: String) {
		guard let (_, platform, version) = runtimeIdentifier.firstMatch(of: Self.search)?.output else {
			self.init(platform: .unknown, version: .unknown)
			return
		}

		self.init(platform: .init(from: platform), version: .init(from: version))
	}
}

private extension Platform {
	init(from string: String?) {
		switch string {
			case "iOS":
				self = .iOS
			case "watchOS":
				self = .watchOS
			case "tvOS":
				self = .tvOS
			default:
				self = .unknown
		}
	}
}

private extension RuntimeVersion {
	init(from string: String?) {
		if let string = string {
			self = .exact(string)
			return
		}

		self = .unknown
	}
}

private extension DeviceState {
	init(from simulatorState: Simulator.State) {
		switch simulatorState {
			case .booted:
				self = .ready
			case .shutdown:
				self = .unavailable
		}
	}
}
