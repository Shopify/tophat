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
	case appStorePackage = "ipa"
	case applicationBundle = "app"
	case androidPackage = "apk"
}

public extension ArtifactFileFormat {
	init?(pathExtension: String) {
		self.init(rawValue: pathExtension)
	}

	var pathExtension: String {
		rawValue
	}
}
