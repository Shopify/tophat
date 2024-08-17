//
//  ToggleableRowIcon.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct ToggleableRowIcon<Content: View>: View {
	@Environment(\.colorScheme) private var colorScheme: ColorScheme
	@Environment(\.buttonPressed) private var buttonPressed: Bool

	let selected: Bool
	let content: () -> Content

	init(selected: Bool, @ViewBuilder content: @escaping () -> Content) {
		self.selected = selected
		self.content = content
	}

	var body: some View {
		content()
			.font(.body)
			.foregroundColor(selected ? .white : .secondary)
			.frame(width: 26, height: 26)
			.background(.quaternary.opacity(selected ? 0 : 1))
			.background(.blue.opacity(selected ? 1 : 0))
			.overlay(.primary.opacity(buttonPressed ? 0.15 : 0))
			.cornerRadius(.infinity)
	}
}
