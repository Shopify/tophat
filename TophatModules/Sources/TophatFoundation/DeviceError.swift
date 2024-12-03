//
//  Device.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// An error that can be thrown when interacting with a `Device`.
public enum DeviceError: Error {
	/// The requested device failed to boot.
	case failedToBoot
	/// The requested device is not available.
	case deviceNotAvailable(state: DeviceState)
	/// The device was unable to install the requested application.
	case failedToInstallApp(bundleUrl: URL, deviceType: DeviceType)
	/// The device was unable to launch the requested application.
	case failedToLaunchApp(bundleId: String, reason: FailedToLaunchAppReason, deviceType: DeviceType)
	/// The device failed to focus.
	case failedToFocus
	/// The device was unable to streamed via scrcpy.
	case failedToStream
	/// The device was unable to open system logs.
	case failedToOpenLogs
	/// The device timed out while waiting to be unlocked.
	case deviceUnlockTimedOut

	public enum FailedToLaunchAppReason: Sendable {
		case unexpected
		case requiresManualProfileTrust
	}
}
