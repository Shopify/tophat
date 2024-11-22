//
//  PinnedApplicationRow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation
@_spi(TophatKitInternal) import TophatKit

struct PinnedApplicationRow: View {
	@Environment(ExtensionHost.self) private var extensionHost
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
				Text(application.name)
					.fontWeight(.medium)

				HStack {
					BadgedText(text: "\(application.platform.description)")

					if case .artifactProvider(let metadata) = application.recipes.first?.source, let artifactProvider = artifactProviders.first(where: { $0.id == metadata.id }) {
						BadgedText(text: artifactProvider.title)
					}
				}
			}
		}
		.opacity(isEnabled ? 1 : 0.5)
	}

	private var artifactProviders: [ArtifactProviderSpecification] {
		extensionHost.availableExtensions.flatMap(\.specification.artifactProviders)
	}
}

private struct BadgedText: View {
	var text: LocalizedStringResource

	var body: some View {
		Text(text)
			.font(.caption)
			.foregroundColor(.secondary)
			.padding(.vertical, 1)
			.padding(.horizontal, 4)
			.background(.quaternary)
			.cornerRadius(3)
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
