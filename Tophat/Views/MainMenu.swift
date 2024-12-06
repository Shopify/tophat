//
//  MainMenu.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-26.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct MainMenu: View {
	@Environment(UpdateController.self) private var updateController
	@Environment(\.showingAdvancedOptions) private var showingAdvancedOptions
	@Environment(\.showOnboardingWindow) private var showOnboardingWindow
	@AppStorage("ShowQuickLaunch") private var showQuickLaunch = true

	@State private var aboutWindowPresented = false

	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Size.menuMargin) {
			MenuHeader()
				.padding(Theme.Size.menuPaddingHorizontal)

			if showQuickLaunch {
				QuickLaunchPanel()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
					.padding(.bottom, Theme.Size.menuMargin)
			} else {
				Divider()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
			}

			DeviceList()

			Divider()
				.padding(.horizontal, Theme.Size.menuPaddingHorizontal)

			VStack(alignment: .leading, spacing: 0) {
				DeselectAllDevicesMenuItem()
				LaunchFromLocationMenuItem()
			}

			if showingAdvancedOptions {
				Divider()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)

				VStack(alignment: .leading, spacing: 0) {
					Button {
						aboutWindowPresented = true
					} label: {
						Text("About Tophat")
					}
					.buttonStyle(.menuItem(activatesApplication: true, blinks: true))

					Button {
						showOnboardingWindow?()
					} label: {
						Text("Show Welcome Window")
					}
					.buttonStyle(.menuItem(activatesApplication: true, blinks: true))
				}
			}

			Divider()
				.padding(.horizontal, Theme.Size.menuPaddingHorizontal)

			VStack(alignment: .leading, spacing: 0) {
				SettingsLink {
					Text("Settings…")
				}
				.buttonStyle(.menuItem(activatesApplication: true, blinks: true))

				Button {
					updateController.checkForUpdates()
				} label: {
					Text("Check for Updates…")
				}
				.buttonStyle(.menuItem(activatesApplication: true, blinks: true))

				Button {
					NSApplication.shared.terminate(nil)
				} label: {
					Text("Quit Tophat")
				}
				.buttonStyle(.menuItem(activatesApplication: true, blinks: true))
			}
		}
		.padding(Theme.Size.menuMargin)
		.frame(width: 336)
		.aboutWindow(isPresented: $aboutWindowPresented) {
			AboutView()
				.showDockIconWhenOpen()
		}
		.modifier(DeviceIsLockedViewModifier())
	}
}
