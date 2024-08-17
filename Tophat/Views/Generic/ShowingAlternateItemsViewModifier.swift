//
//  ShowingAlternateItemsViewModifier.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import SwiftUI

struct ShowingAlternateItemsViewModifier: ViewModifier {
	@Environment(\.scenePhase) private var scenePhase
	@StateObject private var keyModifierFlagsState = KeyModifierFlagsState()

	func body(content: Content) -> some View {
		return content
			.environment(\.showingAlternateItems, keyModifierFlagsState.optionKeyPressed)
			.onChange(of: scenePhase) { newValue in
				// Handle edge case where event monitor is not yet listening while menu is being opened.
				keyModifierFlagsState.optionKeyPressed = NSEvent.modifierFlags.contains(.option)
			}
	}
}

private struct ShowingAlternateItemsKey: EnvironmentKey {
	static let defaultValue = false
}

extension EnvironmentValues {
	var showingAlternateItems: Bool {
		get { self[ShowingAlternateItemsKey.self] }
		set { self[ShowingAlternateItemsKey.self] = newValue }
	}
}

private final class KeyModifierFlagsState: ObservableObject {
	private var monitor: Any?

	@Published var optionKeyPressed: Bool = false

	init() {
		self.monitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
			self?.optionKeyPressed = event.modifierFlags.contains(.option)
			return event
		}
	}

	deinit {
		if monitor != nil {
			NSEvent.removeMonitor(monitor!)
			monitor = nil
		}
	}
}
