//
//  ApplicationError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension ApplicationError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case .missingProvisioningProfile, .deviceNotProvisioned, .applicationNotSigned, .incompatible:
				"This app can’t be installed."
			default:
				nil
		}
	}

	public var failureReason: String? {
		switch self {
			case .missingProvisioningProfile:
				return "The app is missing a provisioning profile required by this device."

			case .deviceNotProvisioned:
				return "This device hasn’t been registered for development."

			case .applicationNotSigned:
				return "This device requires the app to be signed with an Apple Development or Enterprise certificate."

			case .incompatible(let application, let device):
				let applicationPlatformDescription = String(describing: application.platform)
				let applicationTargetsDescription = application.targets.map { String(describing: $0).lowercased() }.formatted(.list(type: .and))
				let devicePlatformDescription = String(describing: device.runtime.platform)
				let deviceTargetDescription = String(describing: device.type).lowercased()

				return "The app was built for \(applicationPlatformDescription) \(applicationTargetsDescription), but \(device.name) is \(devicePlatformDescription.indefiniteArticle) \(devicePlatformDescription) \(deviceTargetDescription)."

			default:
				return nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .deviceNotProvisioned:
				"Add the device in the Apple Developer Portal and rebuild the app."
			case .applicationNotSigned:
				"Make sure the app is signed and try again."
			case .incompatible:
				"Check the platform and destination settings and try again."
			default:
				nil
		}
	}
}
