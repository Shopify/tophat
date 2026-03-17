//
//  Connection.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-12-08.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// The connection by which a device is attached to the system.
public enum Connection: String, Codable, Sendable {
	/// The device is connected through a physical interface such as USB.
	case direct
	/// The device is connected through a network connection such as through 802.11 (Wi-Fi).
	case network
	/// The device is connected through an internal virtual interface on the system.
	case `internal`
}

// MARK: - CustomStringConvertible

extension Connection: CustomStringConvertible {
	public var description: String {
		switch self {
			case .direct:
				return "Direct"
			case .network:
				return "Network"
			case .internal:
				return "Internal"
		}
	}
}
