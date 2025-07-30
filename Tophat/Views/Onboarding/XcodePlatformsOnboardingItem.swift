//
//  XcodePlatformsOnboardingItem.swift
//  Tophat
//
//  Created by Brad Kratky on 2025-01-13.
//  Copyright © 2025 Shopify. All rights reserved.
//

import SwiftUI
import ShellKit

struct XcodePlatformsOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var status: OnboardingItemStatus = .indeterminate

	var body: some View {
		OnboardingItemLayout(title: "Platforms") {
			EmptyView()
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started") {
				Text("Platforms can be installed when launching Xcode for the first time, or using Xcode → Settings → Components.")
					.lineLimit(2, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(status: status) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("In order to install apps on Apple devices or simulators, at least one iOS, watchOS, tvOS, or visionOS platform must be installed.")
						.lineLimit(3, reservesSpace: true)
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
		self.status = .indeterminate
		let isAnySimulatorSDKInstalledResolved = (try? await isAnySimulatorSDKInstalled()) ?? false
		self.status = isAnySimulatorSDKInstalledResolved ? .complete : .incomplete
	}

	private nonisolated func isAnySimulatorSDKInstalled() async throws -> Bool {
		let jsonString = try run(command: .xcodebuild(.showSDKs), log: log)

		guard let data = jsonString.data(using: .utf8) else {
			return false
		}

		let sdks = try JSONDecoder().decode([AppleSDK].self, from: data)

		return sdks.contains { sdk in
			["iphonesimulator", "appletvsimulator", "xrsimulator", "watchsimulator"].contains(sdk.platform)
		}
	}
}

private extension XcodePlatformsOnboardingItem {
	struct AppleSDK: Codable {
		let platform: String
	}
}
