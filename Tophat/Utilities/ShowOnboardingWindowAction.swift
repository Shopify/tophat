//
//  ShowOnboardingWindowAction.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-31.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import SwiftUI

final class ShowOnboardingWindowAction {
	private let symbolicLinkManager: TophatCtlSymbolicLinkManager
	private let utilityPathPreferences: UtilityPathPreferences

	private var onboardingWindow: NSWindow?

	init(symbolicLinkManager: TophatCtlSymbolicLinkManager, utilityPathPreferences: UtilityPathPreferences) {
		self.symbolicLinkManager = symbolicLinkManager
		self.utilityPathPreferences = utilityPathPreferences
	}

	func callAsFunction() {
		if onboardingWindow == nil {
			onboardingWindow = OnboardingWindow {
				OnboardingView()
					.environmentObject(self.symbolicLinkManager)
					.environmentObject(self.utilityPathPreferences)
			}
		}

		onboardingWindow?.center()
		onboardingWindow?.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}
}

private struct ShowOnboardingWindowKey: EnvironmentKey {
	static var defaultValue: ShowOnboardingWindowAction?
}

extension EnvironmentValues {
	var showOnboardingWindow: ShowOnboardingWindowAction? {
		get { self[ShowOnboardingWindowKey.self] }
		set { self[ShowOnboardingWindowKey.self] = newValue }
	}
}
