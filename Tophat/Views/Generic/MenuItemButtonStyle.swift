//
//  MenuItemButtonStyle.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct MenuItemButtonStyle: ButtonStyle {
	@State private var hovering = false

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(.vertical, Theme.Size.menuPaddingVertical)
			.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(.quaternary.opacity(hovering ? 1 : 0))
			.cornerRadius(4)
			.onTrackingHover { hovering in
				self.hovering = hovering
			}
			.environment(\.buttonPressed, configuration.isPressed)
			.environment(\.buttonHovered, hovering)
	}
}

private struct ButtonPressedKey: EnvironmentKey {
	static let defaultValue = false
}

private struct ButtonHoveredKey: EnvironmentKey {
	static let defaultValue = false
}

extension EnvironmentValues {
	var buttonPressed: Bool {
		get { self[ButtonPressedKey.self] }
		set { self[ButtonPressedKey.self] = newValue }
	}

	var buttonHovered: Bool {
		get { self[ButtonHoveredKey.self] }
		set { self[ButtonHoveredKey.self] = newValue }
	}
}
