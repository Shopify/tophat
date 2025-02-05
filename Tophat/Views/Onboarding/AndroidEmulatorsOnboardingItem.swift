//
//  AndroidEmulatorsOnboardingItem.swift
//  Tophat
//
//  Created by Brad Kratky on 2025-01-13.
//  Copyright © 2025 Shopify. All rights reserved.
//

import SwiftUI

struct AndroidEmulatorsOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var isComplete = Self.isEmulatorsConfigured

	var body: some View {
		OnboardingItemLayout(
			title: "Android Emulators",
			description: nil
		) {
			EmptyView()
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Open Android Studio and [create an Android Virtual Device](https://developer.android.com/studio/run/managing-avds).")
						.lineLimit(1, reservesSpace: true)
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
		let newValue = Self.isEmulatorsConfigured

		if self.isComplete != newValue {
			self.isComplete = newValue
		}
	}

	static var isEmulatorsConfigured: Bool {
		let avdPath = "\(NSHomeDirectory())/.android/avd"
		let fileManager = FileManager.default

		guard let avdDirectoryContents = try? fileManager.contentsOfDirectory(atPath: avdPath) else {
			return false
		}
		return avdDirectoryContents.contains { $0.hasSuffix(".avd") }
	}
}
