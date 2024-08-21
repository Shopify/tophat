//
//  XcodeOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct XcodeOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var isComplete = Self.isCommandLineToolReachable

	var body: some View {
		OnboardingItemLayout(
			title: "Xcode",
			description: "Tophat uses Xcode to manage devices and install apps."
		) {
			Image(.xcode)
				.resizable()
				.interpolation(.high)
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started") {
				Text("Xcode can be downloaded from the [Apple Developer Portal](https://developer.apple.com/download/applications/) or by using [xcodes](https://github.com/RobotsAndPencils/xcodes). Make sure to open Xcode to install the Xcode Command Line Tools and the latest SDKs.")
					.lineLimit(3, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Tophat needs Xcode in order to be able to install apps on Apple devices.")
						.lineLimit(2, reservesSpace: true)
				}
			}
		}
		.onChange(of: controlActiveState) { newValue in
			if newValue == .key {
				updateStatus()
			}
		}
	}

	private func updateStatus() {
		let newValue = Self.isCommandLineToolReachable

		if self.isComplete != newValue {
			self.isComplete = newValue
		}
	}

	private static var isCommandLineToolReachable: Bool {
		URL(filePath: "/usr/bin/xcrun").isReachable()
	}
}
