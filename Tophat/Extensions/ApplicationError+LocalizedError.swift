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
			case .missingProvisioningProfile, .deviceNotProvisioned, .applicationNotSigned:
				return "This application canʼt be installed"
			default:
				return nil
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
			default:
				return nil
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .deviceNotProvisioned:
				return "Add your device to the Apple Developer Portal before building the application."
			case .applicationNotSigned:
				return "Ensure that the application is signed and try again."
			default:
				return nil
		}
	}
}
