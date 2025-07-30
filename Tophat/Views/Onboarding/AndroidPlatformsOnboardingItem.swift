//
//  AndroidPlatformsOnboardingItem.swift
//  Tophat
//
//  Created by Brad Kratky on 2025-01-13.
//  Copyright © 2025 Shopify. All rights reserved.
//

import SwiftUI

struct AndroidPlatformsOnboardingItem: View {
	@ObservedObject var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		OnboardingItemLayout(title: "Platforms") {
			EmptyView()
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started") {
				Text("An Android SDK Platform package can be installed using the SDK Manager in Android Studio. [Learn more…](https://developer.android.com/about/versions/16/setup-sdk#install-sdk)")
					.lineLimit(2, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(status: isComplete ? .complete : .incomplete) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("In order to install apps on Android emulators, at least one Android SDK Platform package must be installed.")
						.lineLimit(2, reservesSpace: true)
				}
			}
		}
	}

	private var isComplete: Bool {
		guard let platformsURL = utilityPathPreferences.resolvedAndroidSDKLocation?.appending(path: "platforms") else {
			return false
		}

		let directoryContents = try? FileManager.default.contentsOfDirectory(
			at: platformsURL,
			includingPropertiesForKeys: [.isDirectoryKey]
		)

		return (directoryContents ?? []).contains { itemURL in
			itemURL.isDirectory
		}
	}
}
