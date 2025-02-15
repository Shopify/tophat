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
				SettingsLink {
					Text("Get Started")
				}
				.buttonStyle(
					SettingsLinkAdditionalActionButtonStyle {
						NSRunningApplication.current.activate()
						selectedTab = .apps
					}
				)
			}
			.buttonStyle(InlineButtonStyle())
		}
		.multilineTextAlignment(.center)
	}
}
