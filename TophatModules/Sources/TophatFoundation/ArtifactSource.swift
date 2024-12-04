//
//  ArtifactSource.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// The source of an artifact.
public enum ArtifactSource: Sendable, Equatable, Hashable, Codable {
	case artifactProvider(metadata: ArtifactProviderMetadata)
	case file(url: URL)
}
