//
//  BadgedURL.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-03-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct BadgedURL: View {
	let badges: [String]
	let url: URL

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 6) {
			ForEach(badges, id: \.description) { badge in
				Text(badge)
					.font(.caption)
					.foregroundColor(.secondary)
					.padding(.vertical, 1)
					.padding(.horizontal, 4)
					.background(.quaternary)
					.cornerRadius(3)
			}

			Text(url.absoluteString)
				.font(.caption)
				.foregroundColor(.secondary)
				.lineLimit(1)
				.truncationMode(.middle)
		}
	}
}
