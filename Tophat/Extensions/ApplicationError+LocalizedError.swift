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
				"This application canʼt be installed"
			default:
				nil
		}
	}

	public var failureReason: String? {
		switch self {
			case .missingProvisioningProfile:
				return "The selected device requires that the application contains an embedded provisioning profile, but none was found in the application bundle."

			case .deviceNotProvisioned:
				return "The selected device is not provisioned."

			case .applicationNotSigned:
				return "The selected device requires that the application is signed with an Apple Development or Enterprise certificate."

			case .incompatible(let application, let device):
				let applicationPlatformDescription = String(describing: application.platform)
				let applicationTargetsDescription = application.targets.map { String(describing: $0) }.formatted(.list(type: .and))
				let devicePlatformDescription = String(describing: device.runtime.platform)
				let deviceTargetDescription = String(describing: device.type)

				return "The application was built for \(applicationPlatformDescription) \(applicationTargetsDescription), but \(device.name) is \(devicePlatformDescription.indefiniteArticle) \(devicePlatformDescription) \(deviceTargetDescription)."

			default:
				return nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .deviceNotProvisioned:
				"Add your device to the Apple Developer Portal before building the application."
			case .applicationNotSigned:
				"Ensure that the application is signed and try again."
			case .incompatible:
				"Ensure that the correct artifact is being downloaded and that the correct platform and destination are being specified."
			default:
				nil
		}
	}
}
