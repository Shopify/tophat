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

final class AdbError: Error {}

struct Adb {
	static func listDevices() -> [ConnectedDevice] {
		guard let output = try? run(command: .adb(.devices), log: log) else {
			return []
		}

		return output
			.components(separatedBy: .newlines)
			.dropFirst()
			.compactMap { ConnectedDevice(from: $0) }
	}

	static func getVirtualDeviceName(for device: ConnectedDevice) throws -> String {
		let serial = device.serial

		let output = try firstLine(of: .adb(.getProp(serial: serial, property: "ro.boot.qemu.avd_name")))
			?? firstLine(of: .adb(.getProp(serial: serial, property: "ro.kernel.qemu.avd_name")))
			?? firstLine(of: .adb(.avdName(serial: serial)))

		guard let output else {
			throw AdbError()
		}

		return output
	}

	static func install(serial: String, apkUrl: URL) throws {
		try run(command: .adb(.install(serial: serial, apkUrl: apkUrl)), log: log)
	}

	static func launch(serial: String, componentName: String, arguments: [String]) throws {
		try run(command: .adb(.launch(serial: serial, componentName: componentName, arguments: arguments)), log: log)
	}

	static func resolveActivity(serial: String, packageName: String) throws -> String {
		let output = try run(command: .adb(.resolveActivity(serial: serial, packageName: packageName)), log: log)

		guard let value = output.components(separatedBy: .newlines).last else {
			throw AdbError()
		}

		return value
	}

	static func wait(for device: ConnectedDevice) throws {
		try run(command: .adb(.waitForDevice(serial: device.serial)), log: log)

		// Artificially give Emulator time to communicate with adb
		// TODO: Figure out how Android Studio does it without sleeping
		sleep(3)
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
