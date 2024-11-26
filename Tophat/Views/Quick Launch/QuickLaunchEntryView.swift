//
//  QuickLaunchEntryView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-12.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct QuickLaunchEntryView: View {
	let entry: QuickLaunchEntry

	var body: some View {
		VStack(spacing: 4) {
			AsyncImage(url: entry.iconURL) { image in
				image
					.quickLaunchEntryImageStyle()
			} placeholder: {
				Image(.appIconPlaceholder)
					.quickLaunchEntryImageStyle()
			}

			VStack(spacing: 0) {
				Text(entry.name)
					.font(.caption)
					.lineLimit(1)
					.truncationMode(.tail)

				Text(platformDescription)
					.font(.system(size: 8).weight(.medium))
					.opacity(0.8)
					.foregroundColor(.secondary)
			}
		}
	}

	private var platformDescription: String {
		if entry.platforms.count > 1 {
			return "Multiple"
		}

		if let firstPlatform = entry.platforms.first {
			return String(describing: firstPlatform)
		}

		return String(describing: Platform.unknown)
	}
}

private extension Image {
	func quickLaunchEntryImageStyle() -> some View {
		self
			.resizable()
			.scaledToFit()
			.frame(width: 44, height: 44)
			.cornerRadius(10)
			.shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
	}
}
