//
//  InlineButtonStyle.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct InlineButtonStyle: PrimitiveButtonStyle {
	@Environment(\.colorScheme) private var colorScheme

	func makeBody(configuration: Configuration) -> some View {
		Button {
			configuration.trigger()
		} label: {
			HStack(alignment: .firstTextBaseline, spacing: 4) {
				configuration.label
				Image(systemName: "arrow.forward.circle.fill")
			}
			.font(.caption2)
			.foregroundColor(.secondary)
			.padding(.leading, 8)
			.padding(.trailing, 4)
			.padding(.vertical, 3)
			.background(
				RoundedRectangle(cornerRadius: .infinity)
					.foregroundColor(.black.opacity(backgroundOpacity))
			)
		}
		.buttonStyle(.plain)
	}

	private var backgroundOpacity: CGFloat {
		colorScheme == .dark ? 0.12 : 0.06
	}
}
