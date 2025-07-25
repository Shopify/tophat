//
//  OnboardingTaskList.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct OnboardingTaskList: View {
	@Environment(\.controlActiveState) private var controlActiveState
	@EnvironmentObject private var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		Form {
			Section {
				XcodeOnboardingItem()
				XcodeCommandLineToolsOnboardingItem()
				XcodePlatformsOnboardingItem()
			}

			Section {
				AndroidStudioOnboardingItem()
				AndroidSDKToolsOnboardingItem(utilityPathPreferences: utilityPathPreferences)
				AndroidPlatformsOnboardingItem(utilityPathPreferences: utilityPathPreferences)
			}

			Section {
				ScreenCopyOnboardingItem(utilityPathPreferences: utilityPathPreferences)
			}

			Section {
				CommandLineHelperOnboardingItem()
			}
		}
		.formStyle(.grouped)
		.scrollDisabled(true)
		.onChange(of: controlActiveState) { _, newValue in
			if newValue == .key {
				// Tells UtilityPathPreferences to notify subscribers
				// that it has changed so that they can update accordingly.
				utilityPathPreferences.refresh()
			}
		}
	}
}
