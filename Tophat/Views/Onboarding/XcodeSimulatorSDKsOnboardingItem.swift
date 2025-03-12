//
//  XcodeSDKsOnboardingItem.swift
//  Tophat
//
//  Created by Brad Kratky on 2025-01-13.
//  Copyright © 2025 Shopify. All rights reserved.
//
import SwiftUI

struct XcodeSimulatorSDKsOnboardingItem: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@State private var isComplete = Self.isIosSimulatorSDKsInstalled

	var body: some View {
		OnboardingItemLayout(
			title: "SDKs & Simulators",
			description: nil
		) {
			EmptyView()
		} content: {
			OnboardingItemStatusIcon(state: isComplete ? .complete : .warning) {
				OnboardingPopoverContent(title: "Needs Setup") {
					Text("Open Xcode to be prompted to install the SDKs. [Learn more](https://developer.apple.com/documentation/xcode/installing-additional-simulator-runtimes#Install-Simulator-runtimes-during-first-launch)")
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
