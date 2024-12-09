//
//  AboutView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-31.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct AboutView: View {
	@State private var popoverPresented = false

	var body: some View {
		HStack(alignment: .center, spacing: 36) {
			Image(.settingsAppIcon)
				.resizable()
				.scaledToFit()
				.frame(width: 128, height: 128)

			VStack(alignment: .leading, spacing: 24) {
				VStack(alignment: .leading, spacing: 4) {
					Text(Bundle.main.displayName ?? "Tophat")
						.font(.system(size: 38, weight: .regular))
						.foregroundColor(.primary)

					if let marketingVersion = Bundle.main.shortVersionString, let buildNumber = Bundle.main.buildNumber {
						Text("Version \(marketingVersion) (\(buildNumber))")
							.foregroundColor(.secondary)
							.textSelection(.enabled)
					}
				}

				Text("Made with ❤️ by Lukas Romsicki, Jared Hendry, Caio Lima, Harley Cooper, and the Mobile Foundations team at Shopify.")
					.font(.subheadline)
					.foregroundColor(.secondary)
					.lineLimit(3, reservesSpace: true)

				VStack(alignment: .leading, spacing: 4) {
					Button("Why is it called Tophat?") {
						popoverPresented.toggle()
					}
					.buttonStyle(.link)
					.popover(isPresented: $popoverPresented) {
						VStack(alignment: .leading, spacing: 4) {
							Text("Origins")
								.font(.headline)

							Text("Before the days of GitHub code review requests, Shopify relied on emoji to communicate the state of a code review. When leaving a comment on a pull request, posting a 🎩 emoji indicated that the reviewer not only looked at the code, but also _tested_ it locally to make sure it worked as expected.")
								.lineLimit(5, reservesSpace: true)

							Text("This process became known as “tophatting.”")
								.lineLimit(1, reservesSpace: true)
						}
						.foregroundColor(.primary)
						.padding()
						.frame(maxWidth: 450, alignment: .topLeading)
					}

					if let copyright = Bundle.main.humanReadableCopyright {
						Text(copyright)
							.font(.subheadline)
							.foregroundColor(.secondary)
							.lineLimit(1, reservesSpace: true)
					}
				}
			}
			.frame(maxWidth: 350, alignment: .topLeading)
		}
		.padding([.horizontal, .bottom], 36)
		.padding(.top, 8)
	}
}
