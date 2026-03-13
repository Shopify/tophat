//
//  RuntimeVersion.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-25.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// The version of a particular runtime.
public enum RuntimeVersion: Sendable, Equatable, Hashable {
	case exact(String)
	case unknown
}

// MARK: - Codable

extension RuntimeVersion: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(String.self)

		self = value == "unknown" ? .unknown : .exact(value)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		switch self {
			case .exact(let version):
				try container.encode(version)
			case .unknown:
				try container.encode("unknown")
		}
	}
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
