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
				let targets = providedBuildTypes.map { "\($0.key) \(description(for: $0.value))" }.formatted(.list(type: .or))
				return "No \(targets) Selected"
			case .noMatchingDevices:
				return "Device Not Found"
			case .noSelectedDevices:
				return "No Device Selected"
		}
	}

	var failureReason: String? {
		switch self {
			case .noCompatibleDevices:
				"None of the specified builds are compatible with the selected devices."
			case .noMatchingDevices(let devices):
				"No available device matches \(description(for: devices))."
			default:
				nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .noCompatibleDevices(let providedBuildTypes):
				let text = providedBuildTypes.map { "\($0.key) \(description(for: $0.value).lowercased())" }.formatted(.list(type: .or))
				return "Select \(text.indefiniteArticle) \(text) using the Tophat menu and try again."
			case .noMatchingDevices:
				return "Ensure the specified device is available and try again."
			case .noSelectedDevices:
				return "Select a device from the Tophat menu and try again."
		}
	}

	private func description(for targets: Set<DeviceType>) -> String {
		targets.map { String(describing: $0) }.formatted(.list(type: .or))
	}

	private func description(for devices: [InstallRecipe.Device]) -> String {
		devices.map { "\($0.name) (\($0.platform) \($0.runtimeVersion))" }.formatted(.list(type: .or))
	}
}
