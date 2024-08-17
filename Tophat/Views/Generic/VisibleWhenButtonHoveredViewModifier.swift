//
//  VisibleWhenButtonHoveredViewModifier.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

extension View {
	func visibleWhenButtonHovered() -> some View {
		self.modifier(VisibleWhenButtonHovered())
	}
}

private struct VisibleWhenButtonHovered: ViewModifier {
	@Environment(\.buttonHovered) private var buttonHovered

	func body(content: Content) -> some View {
		if buttonHovered {
			content
		}
	}
}
