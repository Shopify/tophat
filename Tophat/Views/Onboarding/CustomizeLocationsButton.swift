//
//  CustomizeLocationsButton.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-28.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct CustomizeLocationsButton: View {
	@AppStorage("SettingsSelectedTabIndex") var selectedTab: SettingsTab = .general

	var body: some View {
		Group {
			if #available(macOS 14.0, *) {
				#if compiler(>=5.9)
				SettingsLink {
					Text("Customize Locations")
				}
				.buttonStyle(
					SettingsLinkAdditionalActionButtonStyle {
						selectedTab = .locations
					}
				)
				#endif
			} else {
				Button("Customize Locations") {
					selectedTab = .locations
					NSApp.showSettingsWindow()
				}
			}
		}
		.buttonStyle(.link)
	}
}
