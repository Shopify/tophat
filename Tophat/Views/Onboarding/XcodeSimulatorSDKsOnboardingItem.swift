//
//  XcodeSDKsOnboardingItem.swift
//  Tophat
//
//  Created by Brad Kratky on 2025-01-13.
//  Copyright © 2025 Shopify. All rights reserved.
//
import SwiftUI

//Xcode can be downloaded from the [Apple Developer Portal](https://developer.apple.com/download/applications/) or by using [xcodes](https://github.com/RobotsAndPencils/xcodes). Make sure to open Xcode to install the Xcode Command Line Tools and the latest SDKs.

struct XcodeSimulatorSDKsOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var isComplete = Self.isIosSimulatorSDKsInstalled

	var body: some View {
		OnboardingItemLayout(
			title: "Simulator SDKs",
			description: nil
		) {
			EmptyView()
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Open Xcode to be prompted to install the Simulator SDKs. [More information](https://developer.apple.com/documentation/xcode/installing-additional-simulator-runtimes#Install-Simulator-runtimes-during-first-launch).")
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
		let newValue = Self.isIosSimulatorSDKsInstalled

		if self.isComplete != newValue {
			self.isComplete = newValue
		}
	}

	private static var isIosSimulatorSDKsInstalled: Bool {
		let sdkPath = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs"
		let fileManager = FileManager.default

		guard let sdkDirectoryContents = try? fileManager.contentsOfDirectory(atPath: sdkPath) else {
			return false
		}

		return sdkDirectoryContents.contains { $0.hasSuffix(".sdk") }
	}
}
