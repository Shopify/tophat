//
//  ScreenCopyOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-28.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct ScreenCopyOnboardingItem: View {
	@ObservedObject var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		OnboardingItemLayout(
			title: "scrcpy",
			description: "Tophat uses scrcpy to mirror the displays of Android devices."
		) {
            Image(.scrcpy)
				.resizable()
				.interpolation(.high)
				.padding(3)
				.shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started", installCommand: "brew install scrcpy") {
				Text("The [scrcpy](https://github.com/Genymobile/scrcpy) tool can be installed using [Homebrew](https://formulae.brew.sh/formula/scrcpy).")
					.lineLimit(1, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup (Optional)") {
					Text("In order to mirror the display of a connected Android device, scrcpy must be installed.")
						.lineLimit(2, reservesSpace: true)
				}
			}
		}
	}

	private var isComplete: Bool {
		utilityPathPreferences.resolvedScrcpyLocation?.isReachable() ?? false
	}
}
