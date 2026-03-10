//
//  RuntimeVersion.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-25.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// The version of a particular runtime.
public enum RuntimeVersion: Sendable, Codable, Equatable, Hashable {
	case exact(String)
	case unknown
}

extension RuntimeVersion: CustomStringConvertible {
	public var description: String {
		switch self {
			case .exact(let version):
				return version
			case .unknown:
				return "Unknown"
		}
	}
}
