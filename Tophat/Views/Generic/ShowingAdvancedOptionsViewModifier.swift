//
//  ShowingAdvancedOptionsViewModifier.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-20.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct ShowingAdvancedOptions: ViewModifier {
	@Environment(\.scenePhase) private var scenePhase
	@State private var openedWithModifier = false

	func body(content: Content) -> some View {
		content
			.environment(\.showingAdvancedOptions, openedWithModifier)
			.onChange(of: scenePhase) { _, newValue in
				if newValue == .active {
					openedWithModifier = NSEvent.modifierFlags.contains(.option)
				} else {
					openedWithModifier = false
				}
			}
	}
}

extension EnvironmentValues {
	@Entry var showingAdvancedOptions = false
}
