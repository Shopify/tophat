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
	// The delegate will only be written to once, and only by the main app.
	// Safe to ignore isolation checking unless the setup changes.

	/// An object that can provide custom paths to use.
	public nonisolated(unsafe) static var delegate: AndroidPathResolverDelegate?

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
		let cmdLineToolsURL = sdkRoot.appending(path: "cmdline-tools")
		let cmdLineToolsLatestURL = cmdLineToolsURL.appending(paths: ["latest", "bin", name])

		if cmdLineToolsLatestURL.isReachable() {
			return cmdLineToolsLatestURL
		}

		guard let contents = try? FileManager.default.contentsOfDirectory(
			at: cmdLineToolsURL,
			includingPropertiesForKeys: [.isDirectoryKey],
			options: .skipsHiddenFiles
		) else {
			return nil
		}

		let availableVersions = contents.filter { versionURL in
			versionURL.lastPathComponent != "latest" && versionURL.appending(paths: ["bin", name]).isReachable()
		}

		return availableVersions
			.sorted { $0.lastPathComponent.compare($1.lastPathComponent, options: .numeric) == .orderedDescending }
			.first?
			.appending(paths: ["bin", name])
	}

	static func buildTool(named name: String) -> URL? {
		let buildToolsDir = sdkRoot.appending(path: "build-tools")

		guard let contents = try? FileManager.default.contentsOfDirectory(
			at: buildToolsDir,
			includingPropertiesForKeys: [.isDirectoryKey],
			options: .skipsHiddenFiles
		) else {
			return nil
		}

		let toolPaths = contents
			.filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false }
			.map { $0.appending(path: name) }
			.filter { $0.isReachable() }
			.sorted { $0.path > $1.path }

		return toolPaths.first
	}
}
