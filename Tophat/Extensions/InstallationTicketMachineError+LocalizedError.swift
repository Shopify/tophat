//
//  InstallationTicketMachineError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-10-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension InstallationTicketMachineError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .noCompatibleDevices(let providedBuildTypes):
				"No \(description(for: providedBuildTypes)) Selected"
			case .noSelectedDevices:
				"No Device Selected"
			case .deviceNotFound(let identifier):
				"Device Not Found: \(identifier)"
		}
	}

	var failureReason: String? {
		switch self {
			case .noCompatibleDevices:
				"None of the specified builds are compatible with the selected devices."
			case .deviceNotFound:
				"No device matching the specified identifier could be found."
			default:
				nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .noCompatibleDevices(let providedBuildTypes):
				let text = description(for: providedBuildTypes)
				return "Select \(text.indefiniteArticle) \(text) using the Tophat menu and try again."
			case .noSelectedDevices:
				return "Select a device from the Tophat menu and try again."
			case .deviceNotFound:
				return "Make sure the device identifier is correct and the device is available."
		}
	}

	private func description(for providedBuildTypes: [Platform: Set<DeviceType>]) -> String {
		providedBuildTypes.map { "\($0.key) \(description(for: $0.value))" }.formatted(.list(type: .or))
	}

	private func description(for targets: Set<DeviceType>) -> String {
		targets.map { String(describing: $0) }.formatted(.list(type: .or))
	}
}
