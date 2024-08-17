//
//  AndroidStudioOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct AndroidStudioOnboardingItem: View {
	@ObservedObject var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		OnboardingItemLayout(
			title: "Android Studio",
			description: "Tophat uses Android Studio to manage devices and install apps."
		) {
			Image("AndroidStudio")
				.resizable()
				.interpolation(.high)
				.padding(2)
				.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started") {
				Text("Android Studio can be downloaded from [Android Developers](https://developer.android.com/studio). Make sure to open Android Studio to install the latest SDKs and create virtual devices.")
					.lineLimit(3, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Tophat needs Android studio in order to be able to install apps on Android devices.")
						.lineLimit(2, reservesSpace: true)
				}
			}
		}
	}

	private var isComplete: Bool {
		utilityPathPreferences.resolvedAndroidSDKLocation?.isReachable() ?? false
	}
}
