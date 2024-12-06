//
//  SettingsWindow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

enum SettingsTab: Int {
	case general
	case apps
	case devices
	case locations
	case extensions
}

struct SettingsView: View {
	@AppStorage("SettingsSelectedTabIndex") private var selectedTab: SettingsTab = .general

	var body: some View {
		TabView(selection: $selectedTab) {
			GeneralTab()
				.tabItem {
					Label("General", systemImage: "gearshape")
				}
				.tag(SettingsTab.general)

			AppsTab()
				.tabItem {
					Label("Apps", systemImage: "apps.iphone")
				}
				.tag(SettingsTab.apps)

			DevicesTab()
				.tabItem {
					Label("Devices and Simulators", systemImage: "ipad.and.iphone")
				}
				.tag(SettingsTab.devices)

			LocationsTab()
				.tabItem {
					Label("Locations", systemImage: "externaldrive")
				}
				.tag(SettingsTab.locations)

			ExtensionsTab()
				.tabItem {
					Label("Extensions", systemImage: "puzzlepiece.extension")
				}
				.tag(SettingsTab.extensions)
		}
		.frame(width: 600)
		.frame(maxHeight: 500)
		.scrollContentBackground(.hidden)
		.fixedSize()
	}
}
