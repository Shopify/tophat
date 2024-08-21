//
//  GoogleCloudStorageOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct GoogleCloudStorageOnboardingItem: View {
	@ObservedObject var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		OnboardingItemLayout(
			title: "Google Cloud SDK",
			description: "Tophat uses the Google Cloud SDK to download apps."
		) {
			Image(.googleCloudSDK)
				.resizable()
				.interpolation(.high)
				.padding(5)
				.shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started", installCommand: "brew install google-cloud-sdk") {
				Text("The Google Cloud SDK can be installed using [Homebrew](https://formulae.brew.sh/cask/google-cloud-sdk). Make sure to run the `gcloud auth login` command to authenticate.")
					.lineLimit(3, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("If you need to download apps stored in Google Cloud Storage buckets, the Google Cloud SDK needs to be installed.")
						.lineLimit(3, reservesSpace: true)
				}
			}
		}
	}

	private var isComplete: Bool {
		utilityPathPreferences.resolvedGSUtilLocation?.isReachable() ?? false
	}
}
