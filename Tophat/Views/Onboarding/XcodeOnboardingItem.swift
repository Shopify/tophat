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
	@State private var isComplete = Self.isXcodeInstalled

	var body: some View {
		OnboardingItemLayout(
			title: "Xcode",
			description: "Tophat uses Xcode to manage devices and install iOS apps."
		) {
			Image(.xcode)
				.resizable()
				.interpolation(.high)
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Xcode can be downloaded from the [Apple Developer Portal](https://developer.apple.com/download/applications/) or by using [xcodes](https://github.com/RobotsAndPencils/xcodes).")
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
		let newValue = Self.isXcodeInstalled

		if self.isComplete != newValue {
			self.isComplete = newValue
		}
	}

	private static var isXcodeInstalled: Bool {
		let xcodePath = "/Applications/Xcode.app"
		return FileManager.default.fileExists(atPath: xcodePath)
	}
}
