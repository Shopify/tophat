//
//  DeviceState.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// The state of the device.
public enum DeviceState: Sendable {
	case ready
	case unavailable
}

// MARK: - CustomStringConvertible

extension DeviceState: CustomStringConvertible {
	public var description: String {
		switch self {
			case .ready:
				return "Ready"
			case .unavailable:
				return "Unavailable"
		}
	}
}
