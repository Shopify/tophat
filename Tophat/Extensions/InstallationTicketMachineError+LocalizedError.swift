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
		}
	}

	var failureReason: String? {
		switch self {
			case .noCompatibleDevices:
				"None of the specified builds are compatible with the selected devices."
			default:
				nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .noCompatibleDevices(let providedBuildTypes):
				let text = description(for: providedBuildTypes)
				return "Select \(text.startsWithVowel ? "an" : "a") \(text) using the Tophat menu and try again."
			case .noSelectedDevices:
				return "Select a device from the Tophat menu and try again."
		}
	}

	private func description(for providedBuildTypes: [Platform: Set<DeviceType>]) -> String {
		providedBuildTypes.map { "\($0.key) \(description(for: $0.value))" }.formatted(.list(type: .or))
	}

	private func description(for platforms: Set<Platform>) -> String {
		platforms.map { String(describing: $0) }.formatted(.list(type: .or))
	}

	private func description(for targets: Set<DeviceType>) -> String {
		targets.map { String(describing: $0) }.formatted(.list(type: .or))
	}

}

extension Character {
	var isVowel: Bool { "aeiou".contains { String($0).compare(String(self).folding(options: .diacriticInsensitive, locale: nil), options: .caseInsensitive) == .orderedSame } }
}

extension StringProtocol {
	var startsWithVowel: Bool { first?.isVowel == true }
}
