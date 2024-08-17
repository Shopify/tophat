//
//  ToggleableRow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct ToggleableRow<Content: View, IconContent: View>: View {
	let action: () -> Void
	let content: () -> Content
	let icon: () -> IconContent

	init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content, @ViewBuilder icon: @escaping () -> IconContent) {
		self.action = action
		self.content = content
		self.icon = icon
	}

	var body: some View {
		Button(action: action) {
			HStack(alignment: .center, spacing: Theme.Size.menuPaddingHorizontal) {
				icon()
				content()
			}
		}
		.buttonStyle(MenuItemButtonStyle())
	}
}
