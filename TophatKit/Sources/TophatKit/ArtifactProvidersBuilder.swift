//
//  ArtifactProvidersBuilder.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-07.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public protocol ArtifactProviders {}

extension ArtifactProviders {
	var arrayValue: [any ArtifactProvider]? {
		self as? [any ArtifactProvider]
	}
}

extension Array: ArtifactProviders where Element == any ArtifactProvider {}

@resultBuilder
public struct ArtifactProvidersBuilder {
	public static func buildBlock(_ components: (any ArtifactProvider)...) -> some ArtifactProviders {
		components
	}
}
