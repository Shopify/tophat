//
//  DeviceError+LocalizedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension DeviceError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case .failedToBoot:
				return "Failed to start device"
			case .deviceNotAvailable, .deviceUnlockTimedOut:
				return "The device is not available"
			case .failedToInstallApp:
				return "Failed to install application"
			case .failedToLaunchApp(_, .requiresManualProfileTrust, _):
				return "The application was installed"
			case .failedToLaunchApp:
				return "Failed to launch application"
			default:
				return nil
		}
	}

	public var failureReason: String? {
		switch self {
			case .failedToBoot:
				return "The device could not be started due to an unexpected error."
			case .deviceNotAvailable:
				return "The device is not available."
			case .failedToInstallApp(_, deviceType: .physical):
				return "The application could not be installed."
			case .failedToInstallApp:
				return "The application could not be installed due to an unexpected error."
			case .failedToLaunchApp(_, .requiresManualProfileTrust, _):
				return "The enterprise developer must be trusted on the device to launch the app."
			case .failedToLaunchApp:
				return "The application could not be launched due to an unexpected error."
			case .deviceUnlockTimedOut:
				return "The operation timed out while waiting for the device to be unlocked."
			default:
				return nil
		}
	}

	public var recoverySuggestion: String? {
		switch self {
			case .deviceNotAvailable:
				return "Ensure that it is connected and try again."
			case .failedToInstallApp(_, deviceType: .physical), .deviceUnlockTimedOut:
				return "Make sure that the device is connected and unlocked and try again."
			case .failedToLaunchApp(_, .requiresManualProfileTrust, _):
				return "Go to Settings → General → VPN & Device Management to trust the developer."
			case .failedToLaunchApp(_, _, deviceType: .physical):
				return "Make sure that the device is connected and unlocked and try again."
			default:
				return nil
		}
	}
}
