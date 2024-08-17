//
//  DeviceType.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// The type of a device.
public enum DeviceType: String, Codable, CaseIterable {
	case virtual
	case physical
}

// MARK: - CustomStringConvertible

extension DeviceType: CustomStringConvertible {
	public var description: String {
		switch self {
			case .virtual:
				return "virtual"
			case .physical:
				return "physical"
		}
	}
}
