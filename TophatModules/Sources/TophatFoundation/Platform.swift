//
//  Platform.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-10-25.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// A operating system that an executable can run on.
public enum Platform: String, Codable, CaseIterable, Sendable {
	case iOS = "ios"
	case watchOS = "watchos"
	case tvOS = "tvos"
	case android
	case unknown
}

// MARK: - CustomStringConvertible

extension Platform: CustomStringConvertible {
	public var description: String {
		switch self {
			case .iOS:
				return "iOS"
			case .watchOS:
				return "watchOS"
			case .tvOS:
				return "tvOS"
			case .android:
				return "Android"
			case .unknown:
				return "Unknown"
		}
	}
}
