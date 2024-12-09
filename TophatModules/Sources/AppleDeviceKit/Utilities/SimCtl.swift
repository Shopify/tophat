//
//  SimCtl.swift
//  AppleDeviceKit
//
//  Created by Jared Hendry on 2020-09-10.
//  Copyright © 2020 Shopify. All rights reserved.
//

import Foundation
import ShellKit

final class SimCtlError: Error {}

final class SimCtl {
	static func listAvailableDevices() throws -> [Simulator] {
		let output = try run(command: .simCtl(.list(type: .devices, available: true)), log: log)

		guard let data = output.data(using: .utf8) else {
			throw SimCtlError()
		}

		let simulatorList = try JSONDecoder().decode(SimulatorListOutput.self, from: data)

		return simulatorList.devices.flatMap { runtimeIdentifier, devices in
			devices.map { Simulator(from: $0, runtimeIdentifier: runtimeIdentifier) }
		}
	}

	static func start(udid: String) throws {
		try run(command: .simCtl(.boot(device: udid)), log: log)
	}

	static func install(udid: String, bundleUrl: URL) throws {
		try run(command: .simCtl(.install(device: udid, bundleUrl: bundleUrl)), log: log)
	}

	static func launch(udid: String, bundleIdentifier: String, arguments: [String]) throws {
		try run(command: .simCtl(.launch(device: udid, bundleIdentifier: bundleIdentifier, arguments: arguments)), log: log)
	}

	static func terminate(udid: String, bundleIdentifier: String) throws {
		try run(command: .simCtl(.terminate(device: udid, bundleIdentifier: bundleIdentifier)), log: log)
	}
}

private extension Simulator {
	init(from simulatorListDevice: SimulatorListOutput.Device, runtimeIdentifier: String) {
		self.udid = simulatorListDevice.udid
		self.runtimeIdentifier = runtimeIdentifier
		self.name = simulatorListDevice.name
		self.rawState = .init(rawValue: simulatorListDevice.state) ?? .shutdown
	}
}
