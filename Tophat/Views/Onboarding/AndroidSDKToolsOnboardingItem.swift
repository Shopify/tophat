//
//  AndroidSDKToolsOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2025-07-24.
//  Copyright © 2025 Shopify. All rights reserved.
//

import SwiftUI

struct AndroidSDKToolsOnboardingItem: View {
	@ObservedObject var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		OnboardingItemLayout(title: "Android SDK Tools") {
			EmptyView()
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started") {
				Text("The `cmdline-tools`, `build-tools`, `platform-tools`, and `emulator` packages are required and can be installed using SDK Manager in Android Studio. [Learn more…](https://developer.android.com/tools)")
					.lineLimit(3, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(status: isComplete ? .complete : .incomplete) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("In order to install apps on Android devices or emulators, the full suite of Android SDK Tools must be installed.")
						.lineLimit(2, reservesSpace: true)
				}
			}
		}
	}

	private var isComplete: Bool {
		guard let resolvedAndroidSDKLocation = utilityPathPreferences.resolvedAndroidSDKLocation else {
			return false
		}

		return [
			resolvedAndroidSDKLocation.appending(path: "cmdline-tools"),
			resolvedAndroidSDKLocation.appending(path: "build-tools"),
			resolvedAndroidSDKLocation.appending(path: "platform-tools"),
			resolvedAndroidSDKLocation.appending(path: "emulator"),
		].allSatisfy { url in
			let isPopulated = try? FileManager.default.contentsOfDirectory(
				at: url,
				includingPropertiesForKeys: nil
			).contains { itemURL in
				!itemURL.lastPathComponent.starts(with: ".") && itemURL.isReachable()
			}

			return isPopulated ?? false
		}
	}
}
