//
//  AndroidPathResolver.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

// Shorthand for use within the library.
typealias PathResolver = AndroidPathResolver

/// Resolves paths for common Android utilities.
public struct AndroidPathResolver {
	/// An object that can provide custom paths to use.
	public static var delegate: AndroidPathResolverDelegate?

	public static var sdkRoot: URL {
		if let customPath = delegate?.pathToSdkRoot() {
			return customPath
		}

		return FileManager.default
			.homeDirectoryForCurrentUser
			.appending(paths: ["Library", "Android", "sdk"])
	}

	public static var javaHome: URL? {
		if let customPath = delegate?.pathToJavaHome() {
			return customPath
		}

		let jrePaths = [
			// Electric Eel+ JRE location
			"/Applications/Android Studio.app/Contents/jbr/Contents/Home",
			// Arctic Fox+ JRE location
			"/Applications/Android Studio.app/Contents/jre/Contents/Home",
			// Legacy JRE Android Studio location
			"/Applications/Android Studio.app/Contents/jre/jdk/Contents/Home",
		].map { URL(filePath: $0) }

		return jrePaths.first { path in
			path.appending(paths: ["bin", "java"]).isReachable()
		}
	}

	public static var scrcpy: URL? {
		if let customPath = delegate?.pathToScrcpy() {
			return customPath
		}

		let paths = [
			URL(filePath: "/opt/homebrew/bin/scrcpy")
		]

		return paths.first { path in
			path.isReachable()
		}
	}

	static var adb: URL {
		sdkRoot.appending(paths: ["platform-tools", "adb"])
	}

	static func cmdLineTool(named name: String) -> URL? {
		// Prefer versions of cmdline-tools in this order
		let cmdLineReleases = [
			"6.0",
			"5.0",
			"4.0",
			"2.0",
			"latest"
		]

		let availableRelease = cmdLineReleases.first { version in
			sdkRoot.appending(paths: ["cmdline-tools", version, "bin", name]).isReachable()
		}

		guard let availableRelease = availableRelease else {
			return nil
		}

		return sdkRoot.appending(paths: ["cmdline-tools", availableRelease, "bin", name])
	}

	static func buildTool(named name: String) -> URL? {
		let buildToolReleases = [
			"33.0.0",
			"29.0.3",
			"29.0.2",
			"29.0.0",
			"latest"
		]

		let availableRelease = buildToolReleases.first { version in
			sdkRoot.appending(paths: ["build-tools", version, name]).isReachable()
		}

		guard let availableRelease = availableRelease else {
			return nil
		}

		return sdkRoot.appending(paths: ["build-tools", availableRelease, name])
	}
}
