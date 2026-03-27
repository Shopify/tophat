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
			case .failedToBoot, .bootTimedOut:
				return "Failed to Start Device"
			case .deviceNotAvailable:
				return "The device isn’t available."
			case .deviceUnlockTimedOut:
				return "The device is locked."
			case .failedToInstallApp:
				return "Failed to Install App"
			case .failedToLaunchApp(_, .requiresManualProfileTrust, _):
				return "The app was installed, but can’t be launched."
			case .failedToLaunchApp:
				return "Failed to Launch App"
			default:
				return nil
		}
	}

	public var failureReason: String? {
		switch self {
			case .failedToBoot:
				return "An error occurred while preparing the device."
			case .bootTimedOut:
				return "The device took too long to respond after starting."
			case .failedToInstallApp:
				return "An error occurred while installing the app."
			case .failedToLaunchApp(_, .requiresManualProfileTrust, _):
				return "The developer must be trusted on the device before the app can launch."
			case .failedToLaunchApp:
				return "An error occurred while launching the app."
			case .deviceUnlockTimedOut:
				return "The device needs to be unlocked before Tophat can continue."
			default:
				return nil
		}
	}

	public var recoverySuggestion: String? {
		switch self {
			case .failedToBoot, .bootTimedOut:
				return "Make sure the device is set up correctly and try again."
			case .deviceNotAvailable:
				return "Make sure the device is connected and try again."
			case .failedToInstallApp(_, deviceType: .device):
				return "Make sure the device is connected and unlocked and try again."
			case .failedToLaunchApp(_, .requiresManualProfileTrust, _):
				return "On the device, go to Settings → General → VPN & Device Management to trust the developer."
			case .failedToLaunchApp(_, _, deviceType: .device):
				return "Make sure the device is connected and unlocked and try again."
			case .deviceUnlockTimedOut:
				return "Unlock the device and try again."
			default:
				return nil
		}
	}
}
