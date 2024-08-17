//
//  CollapsibleSection.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct CollapsibleSection<Content: View>: View {
	private let title: LocalizedStringKey
	@Binding private var expanded: Bool
	private let content: () -> Content

	init(_ title: LocalizedStringKey, expanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
		self.title = title
		self._expanded = expanded.animation(.easeInOut(duration: 0.3))
		self.content = content
	}

	var body: some View {
		VStack(spacing: 0) {
			Button(action: { expanded.toggle() }) {
				HStack {
					Text(title)
						.sectionHeadingTextStyle()
						.padding(.vertical, 0.5)

					Spacer()

					Image(systemName: "chevron.right")
						.font(.callout)
						.rotationEffect(expanded ? .degrees(90) : .zero)
				}
			}
			.buttonStyle(MenuItemButtonStyle())

			HStack {
				if expanded {
					content()
						.opacity(expanded ? 1 : 0)
						.transition(.move(edge: .top))
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.clipped()
		}
	}
}
