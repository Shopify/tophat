//
//  QuickLaunchEmptyState.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct QuickLaunchEmptyState: View {
	@AppStorage("SettingsSelectedTabIndex") private var selectedTab: SettingsTab = .general

	var body: some View {
		VStack(alignment: .center, spacing: 4) {
			Text("No Apps")
				.sectionHeadingTextStyle()

			Text("Use Quick Launch to install apps with one click.")
				.font(.caption2)
				.opacity(0.8)
				.foregroundColor(.secondary)

			Spacer(minLength: 4)

			Group {
				if #available(macOS 14.0, *) {
					#if compiler(>=5.9)
					SettingsLink {
						Text("Get Started")
					}
					.buttonStyle(
						SettingsLinkAdditionalActionButtonStyle {
							selectedTab = .apps
						}
					)
					#endif
				} else {
					Button("Get Started") {
						selectedTab = .apps
						NSApp.showSettingsWindow()
					}
				}
			}
			.buttonStyle(InlineButtonStyle())
		}
		.multilineTextAlignment(.center)
	}
}
