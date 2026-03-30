//
//  Adb.swift
//  AndroidDeviceKit
//
//  Created by Jared Hendry on 2020-09-22.
//  Copyright © 2020 Shopify. All rights reserved.
//

import Foundation
import RegexBuilder
import ShellKit

enum AdbError: Error {
	case unexpectedOutput
	case invalidLaunchArguments
}

actor AdbBootTimedOutError: Error {
	private(set) var latestError: (any Error)?

	func set(latestError error: any Error) {
		latestError = error
	}

	func clear() {
		latestError = nil
	}
}

struct Adb {
	static func listDevices() -> [ConnectedDevice] {
		guard let output = try? run(command: .adb(.devices), log: log) else {
			return []
		}

		return output
			.components(separatedBy: .newlines)
			.dropFirst()
			.compactMap { shellLine in
				guard var device = ConnectedDevice(from: shellLine) else {
					return nil
				}

				if device.type == .device {
					device.resolveAndroidVersion()
				}

				return device
			}
	}

	static func getVirtualDeviceName(for device: ConnectedDevice) throws -> String {
		let serial = device.serial

		let output = try firstLine(of: .adb(.getProp(serial: serial, property: "ro.boot.qemu.avd_name")))
			?? firstLine(of: .adb(.getProp(serial: serial, property: "ro.kernel.qemu.avd_name")))
			?? firstLine(of: .adb(.avdName(serial: serial)))

		guard let output else {
			throw AdbError.unexpectedOutput
		}

		return output
	}

	static func getVersion(serial: String) throws -> String {
		guard let value = try firstLine(of: .adb(.getProp(serial: serial, property: "ro.build.version.release"))) else {
			throw AdbError.unexpectedOutput
		}

		return value
	}

	static func install(serial: String, apkUrl: URL) throws {
		try run(command: .adb(.install(serial: serial, apkUrl: apkUrl)), log: log)
	}

	static func getAppIcon(serial: String, packageName: String) throws -> URL {
		let remoteJar = "/data/local/tmp/tophat_icon_extractor.jar"
		let remoteIcon = "/data/local/tmp/tophat_icon.png"

		guard let jarURL = Bundle.module.url(forResource: "icon_extractor", withExtension: "jar") else {
			throw AdbError.unexpectedOutput
		}

		try run(command: .adb(.push(serial: serial, localPath: jarURL, remotePath: remoteJar)), timeout: 60, log: log)

		let pathOutput = try run(command: .adb(.packagePath(serial: serial, packageName: packageName)), timeout: 60, log: log)

		guard
			let line = pathOutput.split(separator: "\n").first(where: { $0.hasPrefix("package:") }),
			let apkPath = line.split(separator: ":", maxSplits: 1).last
		else {
			throw AdbError.unexpectedOutput
		}

		let command = "CLASSPATH=\(remoteJar) app_process / IconExtractor \(apkPath) \(packageName) \(remoteIcon)"
		try run(command: .adb(.shell(serial: serial, command: command)), timeout: 60, log: log)

		let localIcon = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
		try run(command: .adb(.pull(serial: serial, remotePath: remoteIcon, localPath: localIcon)), timeout: 60, log: log)

		return localIcon
	}

	static func launch(serial: String, componentName: String, arguments: [String]) throws {
		guard arguments.allSatisfy(\.isSafeShellArgument) else {
			throw AdbError.invalidLaunchArguments
		}

		try run(command: .adb(.launch(serial: serial, componentName: componentName, arguments: arguments)), log: log)
	}

	static func resolveActivity(serial: String, packageName: String) throws -> String {
		let output = try run(command: .adb(.resolveActivity(serial: serial, packageName: packageName)), log: log)

		guard let value = output.components(separatedBy: .newlines).last else {
			throw AdbError.unexpectedOutput
		}

		return value
	}

	static func wait(forSerial serial: String) async throws {
		try run(command: .adb(.waitForDevice(serial: serial)), timeout: 120, log: log)

		let timeoutError = AdbBootTimedOutError()

		try await withThrowingTaskGroup(of: Void.self) { group in
			group.addTask {
				while true {
					do {
						let result = try firstLine(of: .adb(.getProp(serial: serial, property: "sys.boot_completed")))
						await timeoutError.clear()

						if result == "1" {
							return
						}
					} catch {
						await timeoutError.set(latestError: error)
					}

					try await Task.sleep(for: .seconds(1))
				}
			}

			group.addTask {
				try await Task.sleep(for: .seconds(200))
				throw timeoutError
			}

			try await group.next()
			group.cancelAll()
		}
	}

	private static func firstLine(of command: ShellCommand) throws -> String? {
		let output = try run(command: command, log: log)

		guard let firstLineString = output.components(separatedBy: .newlines).first else {
			return nil
		}

		return firstLineString.isEmpty ? nil : firstLineString
	}
}

private extension ConnectedDevice {
	nonisolated(unsafe) private static let anyWhitespace = OneOrMore(.whitespace)
	nonisolated(unsafe) private static let characterOrSymbolCapture = Capture {
		OneOrMore(.any.subtracting(.whitespace))
	}

	nonisolated(unsafe) private static let search = Regex {
		characterOrSymbolCapture
		anyWhitespace
		TryCapture {
			ChoiceOf {
				"device"
				"no device"
				"offline"
			}
		} transform: { ConnectedDevice.State(rawValue: String($0)) }
		Optionally {
			anyWhitespace
			"usb:"
			characterOrSymbolCapture
		}
		Optionally {
			anyWhitespace
			"product:"
			characterOrSymbolCapture
		}
		Optionally {
			anyWhitespace
			"model:"
			characterOrSymbolCapture
		}
		Optionally {
			anyWhitespace
			"device:"
			characterOrSymbolCapture
		}
		Optionally {
			anyWhitespace
			"transport_id:"
			characterOrSymbolCapture
		}
	}

	init?(from shellLine: String) {
		guard let output = shellLine.firstMatch(of: Self.search)?.output else {
			return nil
		}

		let (_, serial, state, usb, product, model, device, transportId) = output

		self.serial = String(serial)
		self._state = state

		if let usb = usb {
			self.usb = String(usb)
		} else {
			self.usb = nil
		}

		if let product = product {
			self.product = String(product)
		} else {
			self.product = nil
		}

		if let model = model {
			self.model = String(model)
		} else {
			self.model = nil
		}

		if let device = device {
			self.device = String(device)
		} else {
			self.device = nil
		}

		if let transportId = transportId {
			self.transportId = String(transportId)
		} else {
			self.transportId = nil
		}
	}
}
