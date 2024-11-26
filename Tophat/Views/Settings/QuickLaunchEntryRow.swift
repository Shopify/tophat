//
//  QuickLaunchEntryRow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation
@_spi(TophatKitInternal) import TophatKit

struct QuickLaunchEntryRow: View {
	@Environment(\.isEnabled) private var isEnabled

	let entry: QuickLaunchEntry

	var body: some View {
		HStack(spacing: 10) {
			AsyncImage(url: entry.iconURL) { image in
				image
					.quickLaunchEntryImageStyle()
			} placeholder: {
				Image(.appIconPlaceholder)
					.quickLaunchEntryImageStyle()
			}
			VStack(alignment: .leading, spacing: 3) {
				Text(entry.name)
					.fontWeight(.medium)

				HStack {
					ForEach(Array(entry.platforms), id: \.self) { platform in
						BadgedText(text: Text(String(describing: platform)))
					}
				}
			}
		}
		.opacity(isEnabled ? 1 : 0.5)
	}
}

struct BadgedText: View {
	var text: Text

	var body: some View {
		text
			.font(.caption)
			.foregroundColor(.secondary)
			.padding(.vertical, 1)
			.padding(.horizontal, 4)
			.background(.quaternary)
			.cornerRadius(3)
	}
}

private extension Image {
	func quickLaunchEntryImageStyle() -> some View {
		self
			.resizable()
			.scaledToFit()
			.frame(width: 32, height: 32)
			.cornerRadius(8)
			.shadow(color: .black.opacity(0.2), radius: 0.5, x: 0, y: 0.5)
	}
}
