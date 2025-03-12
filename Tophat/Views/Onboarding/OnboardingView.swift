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

	private let iconSize: CGFloat = 128
	private let gradientDiameter: CGFloat = 280

	var body: some View {
		HStack(spacing: 0) {
			VStack(alignment: .center, spacing: 0) {
				ZStack {
					RadialGradient(
						gradient: Gradient(colors: [.onboardingGradient.opacity(0.3), Color.clear]),
						center: .center,
						startRadius: 0,
						endRadius: gradientDiameter / 2)
					.frame(width: gradientDiameter, height: gradientDiameter)

					Image(.settingsAppIcon)
						.resizable()
						.scaledToFit()
						.frame(width: iconSize, height: iconSize)
				}
				.frame(height: iconSize)

				Text("Tophat")
					.font(.system(size: 36, weight: .bold))
					.foregroundColor(.primary)

				if let marketingVersion = Bundle.main.shortVersionString {
					Text("Version \(marketingVersion)")
						.foregroundColor(.secondary)
						.padding(.top, 4)
				}

				CustomizeLocationsButton()
					.padding(.top, 24)
			}
			.frame(minWidth: 400, maxHeight: .infinity)
			.background(Color.onboardingBackground)

			VStack(spacing: 4) {
				OnboardingTaskList()

				Button("Start Using Tophat") {
					customWindowPresentation?.dismiss()
				}
				.controlSize(.large)
				.keyboardShortcut(.return)
				.padding(.bottom, 28)
			}
		}
	}
}
