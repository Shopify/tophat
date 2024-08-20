//
//  OnboardingView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
	@Environment(\.customWindowPresentation) private var customWindowPresentation

	var body: some View {
		VStack(alignment: .center, spacing: 36) {
			VStack(spacing: 8) {
                Image(.settingsAppIcon)
					.resizable()
					.scaledToFit()
					.frame(width: 128, height: 128)

				Text("Welcome to Tophat")
					.font(.system(size: 38, weight: .regular))
					.foregroundColor(.primary)

				if let marketingVersion = Bundle.main.shortVersionString, let buildNumber = Bundle.main.buildNumber {
					Text("Version \(marketingVersion) (\(buildNumber))")
						.foregroundColor(.secondary)
				}
			}

			VStack(spacing: 0) {
				Text("Make sure the following developer tools are set up to get the most from Tophat.")
					.font(.body)
					.foregroundColor(.primary)
					.padding(.horizontal, 56)

				OnboardingTaskList()

				VStack(spacing: 32) {
					CustomizeLocationsButton()

					Button("Start Using Tophat") {
						customWindowPresentation?.dismiss()
					}
					.controlSize(.large)
					.keyboardShortcut(.return)
				}
			}
		}
		.padding(.top, 56)
		.padding(.horizontal, 8)
		.padding(.bottom, 28)
	}
}
