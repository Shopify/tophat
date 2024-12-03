//
//  ArtifactProviderResult.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public protocol ArtifactProviderResult {}

public struct ArtifactProviderResultContainer: Codable, ArtifactProviderResult, Sendable {
	public var localURL: URL
}

public extension ArtifactProviderResult {
	static func result(localURL: URL) -> Self where Self == ArtifactProviderResultContainer {
		return .init(localURL: localURL)
	}
}
