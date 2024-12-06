//
//  View+ShowDockIconWhenOpen.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-09-01.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI

extension View {
	func showDockIconWhenOpen() -> some View {
		modifier(ShowDockIconWhenOpenViewModifier())
	}
}

private struct ShowDockIconWhenOpenViewModifier: ViewModifier {
	@Environment(\.controlActiveState) private var controlActiveState

	func body(content: Content) -> some View {
		content
			.onChange(of: controlActiveState, initial: true) { oldValue, newValue in
				if newValue != .inactive, NSApp.activationPolicy() == .accessory {
					NSApp.setActivationPolicy(.regular)
				}
			}
	}
}
