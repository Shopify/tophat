//
//  URL+ArtifactSource.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2026-03-09.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension URL {
	var artifactSource: ArtifactSource {
		if isFileURL {
			.file(url: self)
		} else {
			.artifactProvider(
				metadata: ArtifactProviderMetadata(
					id: "http",
					parameters: ["url": absoluteString]
				)
			)
		}
	}
}
