//
//  ArtifactProviderValue.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public protocol ArtifactProviderValue {
	init?(stringRepresentation: String)
}

extension String: ArtifactProviderValue {
	public init?(stringRepresentation: String) {
		self = stringRepresentation
	}
}

// MARK: - RawRepresentable

extension RawRepresentable where Self: ArtifactProviderValue, RawValue: ArtifactProviderValue {
	public init?(stringRepresentation: String) {
		if let value = RawValue(stringRepresentation: stringRepresentation) {
			self.init(rawValue: value)
		} else {
			return nil
		}
	}
}

// MARK: - Optional

extension Optional: ArtifactProviderValue where Wrapped: ArtifactProviderValue {
	public init?(stringRepresentation: String) {
		if let value = Wrapped(stringRepresentation: stringRepresentation) {
			self.init(value)
		} else {
			return nil
		}
	}
}

// MARK: - URL

extension URL: ArtifactProviderValue {
	public init?(stringRepresentation: String) {
		self.init(string: stringRepresentation)
	}
}

// MARK: - LosslessStringConvertible

extension LosslessStringConvertible where Self: ArtifactProviderValue {
	public init?(stringRepresentation: String) {
		self.init(stringRepresentation)
	}
}

extension Int: ArtifactProviderValue {}
extension Double: ArtifactProviderValue {}
extension Float: ArtifactProviderValue {}
extension Bool: ArtifactProviderValue {}
