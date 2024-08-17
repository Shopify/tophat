//
//  OnboardingPopoverContent.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-28.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct OnboardingPopoverContent<Content: View>: View {
	let title: LocalizedStringKey
	var installCommand: String? = nil
	@ViewBuilder let content: () -> Content

	@State private var copied = false

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(title)
				.font(.headline)

			VStack(alignment: .leading, spacing: 12) {
				content()

				if let installCommand = installCommand {
					Button("Copy Install Command") {
						copy(text: installCommand)
						copied = true
					}
					.disabled(copied)
				}
			}
		}
		.onDisappear {
			copied = false
		}
	}

	private func copy(text: String) {
		let pasteboard = NSPasteboard.general
		pasteboard.declareTypes([.string], owner: nil)
		pasteboard.setString(text, forType: .string)
	}
}
