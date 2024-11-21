//
//  InfoButton.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI

struct InfoButton: View {
	@State private var isPresented = false

	var help: LocalizedStringResource

	var body: some View {
		Button("Help", systemImage: "info.circle") {
			isPresented.toggle()
		}
		.labelStyle(.iconOnly)
		.buttonStyle(.borderless)
		.popover(isPresented: $isPresented) {
			ScrollView {
				Text(help)
					.padding()
			}
			.frame(width: 400, height: 120, alignment: .topLeading)
		}
	}
}
