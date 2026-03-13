//
//  List+Devices.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2026-03-13.
//  Copyright © 2026 Shopify. All rights reserved.
//

import ArgumentParser
import TophatControlServices
import Foundation

extension List {
	struct Devices: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Lists all devices available to Tophat."
		)

		@Flag(name: .long, help: "Output the result as JSON.")
		var json = false

		func run() async throws {
			checkIfHostAppIsRunning()

			let reply = try await TophatRemoteControlService().send(request: ListDevicesRequest())

			if json {
				let encoder = JSONEncoder()
				encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
				let data = try encoder.encode(reply.devices)
				print(String(data: data, encoding: .utf8)!)
			} else {
				print("Devices:")

				for device in reply.devices {
					print()

					print("‣\u{001B}[1m", device.name, "\u{001B}[22m")
					print("  Type:", device.type)
					print("  Platform:", device.platform)
					print("  Version:", device.runtimeVersion)
					print("  Connection:", device.connection)
					print("  State:", device.state)
				}
			}
		}
	}
}
