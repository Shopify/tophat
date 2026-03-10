//
//  Emulator.swift
//  AndroidDeviceKit
//
//  Created by Jared Hendry on 2020-09-10.
//  Copyright © 2020 Shopify. All rights reserved.
//

import Foundation
import Network
import ShellKit

struct Emulator {
	private static let portSequence = PortSequence()

	/// - returns: The serial of the device that was booted.
	static func start(name: String) async throws -> String {
		let output = try await portSequence.withAvailablePort { reportConsolePort in
			try run(
				command: .emulator(.startDevice(name: name, reportConsolePort: reportConsolePort)),
				log: log
			)
		}

		guard let consolePort = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) else {
			throw EmulatorError.failedToReadPort
		}

		return "emulator-\(consolePort)"
	}
}

enum EmulatorError: Error {
	case failedToReadPort
	case noAvailablePort
}

private actor PortSequence {
	private let startPort: UInt16 = 49152
	private let maxAttempts = 20

	private var inFlight: Set<UInt16> = []

	func withAvailablePort<T>(_ body: (Int) async throws -> T) async throws -> T {
		guard let port = reservePort() else {
			throw EmulatorError.noAvailablePort
		}

		defer { inFlight.remove(port) }
		return try await body(Int(port))
	}

	private func reservePort() -> UInt16? {
		for attempt in 0..<maxAttempts {
			let port = startPort + UInt16(attempt)

			if !inFlight.contains(port), isAvailable(port) {
				inFlight.insert(port)
				return port
			}
		}

		return nil
	}

	private func isAvailable(_ port: UInt16) -> Bool {
		guard let listener = try? NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!) else {
			return false
		}
		listener.cancel()
		return true
	}
}
