//
//  QuickLaunchAppView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-12.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct QuickLaunchAppView: View {
	let app: PinnedApplication

	var body: some View {
		VStack(spacing: 4) {
			AsyncImage(url: app.icon?.url) { image in
				image
					.pinnedApplicationImageStyle()
			} placeholder: {
                Image(.appIconPlaceholder)
					.pinnedApplicationImageStyle()
			}

			VStack(spacing: 0) {
				Text(app.name)
					.font(.caption)
					.lineLimit(1)
					.truncationMode(.tail)

				Text(String(describing: app.platform))
					.font(.system(size: 8).weight(.medium))
					.opacity(0.8)
					.foregroundColor(.secondary)
			}

		}
	}
}

private extension Image {
	func pinnedApplicationImageStyle() -> some View {
		self
			.resizable()
			.scaledToFit()
			.frame(width: 44, height: 44)
			.cornerRadius(10)
			.shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
	}
}
