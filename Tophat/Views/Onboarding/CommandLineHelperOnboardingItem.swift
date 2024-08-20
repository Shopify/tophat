//
//  CommandLineHelperOnboardingItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct CommandLineHelperOnboardingItem: View {
	@EnvironmentObject private var symbolicLinkManager: TophatCtlSymbolicLinkManager

	var body: some View {
		OnboardingItemLayout(
			title: "Command Line Helper",
			description: "The `tophatctl` command allows you to control Tophat from the command line."
		) {
            Image(.terminal)
				.resizable()
		} content: {
			if symbolicLinkManager.isInstalled {
				OnboardingItemStatusIcon(state: .complete)
			} else {
				Button("Install…") {
					Task {
						await symbolicLinkManager.install()
						NSApp.activate(ignoringOtherApps: true)
					}
				}
			}
		}
	}
}
