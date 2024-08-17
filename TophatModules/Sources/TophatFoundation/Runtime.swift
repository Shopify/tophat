//
//  Runtime.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// Describes the platform and version of a particular runtime.
public struct Runtime {
	/// The operating system category of the runtime.
	public let platform: Platform

	/// The version of the runtime.
	public let version: RuntimeVersion

	/// Creates a new runtime instance with the provided parameters.
	/// - Parameters:
	///   - platform: The platform.
	///   - version: The version.
	public init(platform: Platform, version: RuntimeVersion) {
		self.platform = platform
		self.version = version
	}
}

// MARK: - CustomStringConvertible

extension Runtime: CustomStringConvertible {
	public var description: String {
		if case .unknown = version {
			return String(describing: platform)
		}

		return "\(platform) \(version)"
	}
}
