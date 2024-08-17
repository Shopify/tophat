//
//  UtilityPathPreferences.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import AndroidDeviceKit
import GoogleStorageKit

final class UtilityPathPreferences: ObservableObject {
	@AppStorage("AndroidSDKPath") var preferredAndroidSDKPath: String?
	@AppStorage("JavaHomePath") var preferredJavaHomePath: String?
	@AppStorage("ScrcpyPath") var preferredScrcpyPath: String?
	@AppStorage("GSUtilPath") var preferredGSUtilPath: String?

	var resolvedAndroidSDKLocation: URL? {
		AndroidPathResolver.sdkRoot
	}

	var resolvedJavaHomeLocation: URL? {
		AndroidPathResolver.javaHome
	}

	var resolvedScrcpyLocation: URL? {
		AndroidPathResolver.scrcpy
	}

	var resolvedGSUtilLocation: URL? {
		GoogleStoragePathResolver.gsUtilPath
	}

	@MainActor
	func refresh() {
		objectWillChange.send()
	}
}

extension UtilityPathPreferences: AndroidPathResolverDelegate {
	func pathToSdkRoot() -> URL? {
		guard let preferredAndroidSDKPath = preferredAndroidSDKPath else {
			return nil
		}
		return URL(fileURLWithPath: preferredAndroidSDKPath)
	}

	func pathToJavaHome() -> URL? {
		guard let preferredJavaHomePath = preferredJavaHomePath else {
			return nil
		}
		return URL(fileURLWithPath: preferredJavaHomePath)
	}

	func pathToScrcpy() -> URL? {
		guard let preferredScrcpyPath = preferredScrcpyPath else {
			return nil
		}
		return URL(fileURLWithPath: preferredScrcpyPath)
	}
}

extension UtilityPathPreferences: GoogleStoragePathResolverDelegate {
	func pathToGSUtil() -> URL? {
		guard let preferredGSUtilPath = preferredGSUtilPath else {
			return nil
		}
		return URL(filePath: preferredGSUtilPath)
	}
}
