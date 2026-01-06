//
//  ArtifactFileFormat.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2022-11-21.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// The file format of an artifact.
public enum ArtifactFileFormat: String, CaseIterable {
	case zip = "zip"
	case tarGzip = "tar.gz"
	case appStorePackage = "ipa"
	case applicationBundle = "app"
	case androidPackage = "apk"
}

public extension ArtifactFileFormat {
	init?(pathExtension: String) {
		self.init(rawValue: pathExtension)
	}

  /// Initializes from a file URL, supporting multi-part extensions generically
    init?(url: URL) {
        let ext = url.fullPathExtension.lowercased()
        self.init(pathExtension: ext)
    }

	var pathExtension: String {
		rawValue
	}
}
