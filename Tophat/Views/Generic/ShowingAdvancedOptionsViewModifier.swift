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
			.onChange(of: scenePhase) { newValue in
				if newValue == .active {
					openedWithModifier = NSEvent.modifierFlags.contains(.option)
				} else {
					openedWithModifier = false
				}
			}
	}
}

private struct ShowingAdvancedOptionsKey: EnvironmentKey {
	static var defaultValue: Bool = false
}

extension EnvironmentValues {
	var showingAdvancedOptions: Bool {
		get { self[ShowingAdvancedOptionsKey.self] }
		set { self[ShowingAdvancedOptionsKey.self] = newValue }
	}
}
