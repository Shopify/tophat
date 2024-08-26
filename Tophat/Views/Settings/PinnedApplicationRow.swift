//
//  PinnedApplicationRow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct PinnedApplicationRow: View {
	@Environment(\.isEnabled) private var isEnabled

	let application: PinnedApplication

	var body: some View {
		HStack(spacing: 10) {
			AsyncImage(url: application.icon?.url) { image in
				image
					.pinnedApplicationImageStyle()
			} placeholder: {
				Image(.appIconPlaceholder)
					.pinnedApplicationImageStyle()
			}
			VStack(alignment: .leading, spacing: 3) {
				Text("\(application.name) (\(application.platform.description))")
					.fontWeight(.medium)

				ForEach(application.artifacts, id: \.url) { artifact in
					BadgedURL(badges: formatted(targets: artifact.targets), url: artifact.url)
				}
			}
		}
		.opacity(isEnabled ? 1 : 0.5)
	}

	private func formatted(targets: Set<DeviceType>) -> [String] {
		Array(targets)
			.map { String(describing: $0).capitalized }
			.sorted()
	}
}

private extension Image {
	func pinnedApplicationImageStyle() -> some View {
		self
			.resizable()
			.scaledToFit()
			.frame(width: 32, height: 32)
			.cornerRadius(8)
			.shadow(color: .black.opacity(0.2), radius: 0.5, x: 0, y: 0.5)
	}
}
