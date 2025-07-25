//
//  XcodeOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import ShellKit

struct XcodeOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var status: OnboardingItemStatus = .indeterminate

	var body: some View {
		OnboardingItemLayout(
			title: "Xcode",
			description: "Tophat uses Xcode to install apps on devices and simulators."
		) {
			Image(.xcode)
				.resizable()
				.interpolation(.high)
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started") {
				Text("Xcode can be downloaded from [Apple Developer](https://developer.apple.com/download/applications/). Make sure to open Xcode to complete the required setup tasks.")
					.lineLimit(2, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(status: status) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("In order to install apps on Apple devices or simulators, Xcode must be installed and set up.")
						.lineLimit(2, reservesSpace: true)
				}
			}
		}
		.onChange(of: controlActiveState) { _, newValue in
			if newValue == .key {
				Task { await updateStatus() }
			}
		}
	}

	private func updateStatus() async {
		status = .indeterminate
		let isXcodeInstalledResolved = (try? await isXcodeInstalled()) ?? false
		status = isXcodeInstalledResolved ? .complete : .incomplete
	}

	private nonisolated func isXcodeInstalled() async throws -> Bool {
		let output = try run(command: .xcodebuild(.version), log: log)
		return output.contains("Build version")
	}
}
