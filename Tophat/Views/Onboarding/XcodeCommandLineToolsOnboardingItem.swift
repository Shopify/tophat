//
//  Xcode.swift
//  Tophat
//
//  Created by Brad Kratky on 2025-01-10.
//  Copyright © 2025 Shopify. All rights reserved.
//
import SwiftUI

struct XcodeCommandLineToolsOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var isComplete = Self.isCommandLineToolsReachable

	var body: some View {
		OnboardingItemLayout(title: "Xcode Command Line Tools") {
			EmptyView()
		} infoPopoverContent: {
			OnboardingPopoverContent(title: "Getting Started") {
				Text("The Xcode Command Line Tools are installed automatically the first time you open Xcode.")
					.lineLimit(2, reservesSpace: true)
			}
		} content: {
			OnboardingItemStatusIcon(status: isComplete ? .complete : .incomplete) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("In order to install apps on Apple devices or simulators, the Xcode Command Line Tools must be installed.")
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
		let newValue = Self.isCommandLineToolsReachable

		if self.isComplete != newValue {
			self.isComplete = newValue
		}
	}

	private static var isCommandLineToolsReachable: Bool {
		URL(filePath: "/usr/bin/xcrun").isReachable()
	}
}
