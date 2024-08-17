//
//  OnboardingItemLayout.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct OnboardingItemLayout<ImageView: View, InfoPopoverContent: View, Content: View>: View {
	@State private var instructionsPopoverPresented = false

	private let title: LocalizedStringKey
	private let image: () -> ImageView
	private let description: LocalizedStringKey

	private let infoPopoverContent: () -> InfoPopoverContent
	private let showInfoIcon: Bool
	private let content: () -> Content

	init(
		title: LocalizedStringKey,
		description: LocalizedStringKey,
		@ViewBuilder image: @escaping () -> ImageView,
		@ViewBuilder infoPopoverContent: @escaping () -> InfoPopoverContent,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.title = title
		self.image = image
		self.description = description
		self.infoPopoverContent = infoPopoverContent
		self.showInfoIcon = true
		self.content = content
	}

	init(
		title: LocalizedStringKey,
		description: LocalizedStringKey,
		@ViewBuilder image: @escaping () -> ImageView,
		@ViewBuilder content: @escaping () -> Content
	) where InfoPopoverContent == EmptyView {
		self.title = title
		self.image = image
		self.description = description
		self.infoPopoverContent = { EmptyView() }
		self.showInfoIcon = false
		self.content = content
	}

	var body: some View {
		HStack(spacing: 12) {
			image()
				.scaledToFit()
				.frame(width: 48, height: 48)

			VStack(alignment: .leading, spacing: 2) {
				HStack(spacing: 6) {
					Text(title)
						.fontWeight(.medium)

					if showInfoIcon {
						Button {
							instructionsPopoverPresented.toggle()
						} label: {
							Image(systemName: "info.circle")
								.foregroundColor(.secondary)
						}
						.buttonStyle(.plain)
						.popover(isPresented: $instructionsPopoverPresented, arrowEdge: .bottom) {
							infoPopoverContent()
								.padding()
								.frame(maxWidth: 400, alignment: .topLeading)
						}
					}
				}
				Text(description)
					.font(.subheadline)
					.foregroundColor(.secondary)
			}

			Spacer()

			content()
		}
	}
}
