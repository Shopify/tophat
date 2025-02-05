//
//  AndroidStudioOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct AndroidStudioOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var isComplete = Self.isAndroidStudioInstalled

	var body: some View {
		OnboardingItemLayout(
			title: "Android Studio",
			description: "Tophat uses Android Studio to manage devices and install apps."
		) {
			Image(.androidStudio)
				.resizable()
				.interpolation(.high)
				.padding(2)
				.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Android Studio can be downloaded from [Android Developers](https://developer.android.com/studio).")
						.lineLimit(2, reservesSpace: true)
				}
			}
		}
		.onChange(of: controlActiveState) { _, newValue in
			if newValue == .key {
				updateStatus()
			}
		}
	}

	private func updateStatus() {
		let newValue = Self.isAndroidStudioInstalled

		if self.isComplete != newValue {
			self.isComplete = newValue
		}
	}

	private static var isAndroidStudioInstalled: Bool {
		let androidStudioPath = "/Applications/Android Studio.app"
		return FileManager.default.fileExists(atPath: androidStudioPath)
	}
}
