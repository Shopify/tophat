//
//  AndroidSDKsOnboardingItem.swift
//  Tophat
//
//  Created by Brad Kratky on 2025-01-13.
//  Copyright © 2025 Shopify. All rights reserved.
//

import SwiftUI

struct AndroidSDKsOnboardingItem: View {
	@ObservedObject var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		OnboardingItemLayout(
			title: "SDKs",
			description: nil
		) {
			EmptyView()
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Open Android Studio and install the latest SDKs. [Learn more](https://developer.android.com/about/versions/14/setup-sdk#install-sdk)")
						.lineLimit(1, reservesSpace: true)
				}
			}
		}
	}

	private var isComplete: Bool {
		utilityPathPreferences.resolvedAndroidSDKLocation?.isReachable() ?? false
	}
}
