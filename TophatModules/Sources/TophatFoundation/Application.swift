//
//  Application.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-11-21.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// An installable application found on the local file system.
public protocol Application: Sendable, Deletable {
	/// The display name of the application.
	var name: String? { get }

	/// The URL of the application.
	var url: URL { get }

	/// The URL of the application icon.
	var icon: URL? { get }

	/// The target devices of the application build.
	var targets: Set<DeviceType> { get }

	/// The platform that the application build is compiled for.
	var platform: Platform { get }

	/// The bundle identifier of the application.
	var bundleIdentifier: String { get throws }

	/// Whether the application can be installed on the given device.
	func validateEligibility(for device: Device) throws
}
