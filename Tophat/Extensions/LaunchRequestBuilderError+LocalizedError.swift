//
//  LaunchRequestBuilderError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension LaunchRequestBuilderError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .failedToFindCompatibleDevice(let platform, _):
				return "No \(platform) device selected"

			case .failedToFindCompatibleArtifact:
				return "This artifact is not compatible with the selected device"
		}
	}

	var failureReason: String? {
		switch self {
			case .failedToFindCompatibleArtifact(let device, let availableTargets):
				return "\(device.name) is a \(device.type) device, but the requested artifact was only built for \(description(for: availableTargets)) devices."
			default:
				return nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .failedToFindCompatibleDevice(let platform, let availableTargets):
				return "Select a \(description(for: availableTargets)) \(platform) device using the Tophat menu and try again."

			case .failedToFindCompatibleArtifact(let device, let availableTargets):
				return "Select a \(description(for: availableTargets)) \(device.runtime.platform) device and try again."
		}
	}

	private func description(for targets: Set<DeviceType>) -> String {
		targets.map { String(describing: $0) }.formatted(.list(type: .or))
	}
}
