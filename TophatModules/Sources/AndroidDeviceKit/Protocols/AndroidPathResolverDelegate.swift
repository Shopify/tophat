//
//  AndroidPathResolverDelegate.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// A delegate that provides customized settings for the Android environment.
public protocol AndroidPathResolverDelegate {
	/// If a custom Android SDK root should be used, return it from this function.
	/// - Returns: The path to the Android SDK root.
	func pathToSdkRoot() -> URL?

	/// If a custom Java home should be used, return it from this function.
	/// - Returns: The path to Java home.
	func pathToJavaHome() -> URL?

	/// If a custom `scrcpy` path should be used, return it from this function.
	/// - Returns: The path to the `scrcpy` executable.
	func pathToScrcpy() -> URL?
}
