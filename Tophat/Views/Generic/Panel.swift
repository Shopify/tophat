//
//  Panel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import VisualEffects

struct Panel<Content: View>: View {
	@Environment(\.colorScheme) private var colorScheme

	private let content: () -> Content

	init(@ViewBuilder content: @escaping () -> Content) {
		self.content = content
	}

	var body: some View {
		if #available(macOS 26.0, *) {
			content()
				.glassEffect(.clear, in: RoundedRectangle(cornerRadius: baseCornerRadius))
		} else {
			content()
				.background(VisualEffectBlur(material: .menu, blendingMode: .behindWindow, state: .active))
				.cornerRadius(baseCornerRadius)
				.overlay(
					RoundedRectangle(cornerRadius: baseCornerRadius)
						.strokeBorder(.white.opacity(showProminentBorder ? 0.18 : 0), lineWidth: lineWidth)
				)
				.padding(lineWidth)
				.overlay(
					RoundedRectangle(cornerRadius: baseCornerRadius + lineWidth)
						.strokeBorder(.black.opacity(showProminentBorder ? 0.4 : 0), lineWidth: lineWidth)
				)
				.compositingGroup()
				.shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
		}
	}

	private var showProminentBorder: Bool {
		colorScheme == .dark
	}

	private var baseCornerRadius: CGFloat {
		Theme.Size.panelCornerRadius
	}

	private var lineWidth: CGFloat {
		Theme.Size.hairlineWidth
	}
}
