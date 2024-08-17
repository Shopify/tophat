//
//  GoogleStoragePathResolverDelegate.swift
//  GoogleStorageKit
//
//  Created by Lukas Romsicki on 2023-01-24.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

/// A delegate that provides customized settings for the Google Storage environment.
public protocol GoogleStoragePathResolverDelegate {
	/// If a custom `gsutil` path should be used, return it from this function.
	/// - Returns: The path to the `gsutil` executable.
	func pathToGSUtil() -> URL?
}
