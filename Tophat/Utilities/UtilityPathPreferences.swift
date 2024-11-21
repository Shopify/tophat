//
//  UtilityPathPreferences.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import AndroidDeviceKit

final class UtilityPathPreferences: ObservableObject {
	@AppStorage("AndroidSDKPath") var preferredAndroidSDKPath: String?
	@AppStorage("JavaHomePath") var preferredJavaHomePath: String?
	@AppStorage("ScrcpyPath") var preferredScrcpyPath: String?

	var resolvedAndroidSDKLocation: URL? {
		AndroidPathResolver.sdkRoot
	}

	var resolvedJavaHomeLocation: URL? {
		AndroidPathResolver.javaHome
	}

	var resolvedScrcpyLocation: URL? {
		AndroidPathResolver.scrcpy
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
