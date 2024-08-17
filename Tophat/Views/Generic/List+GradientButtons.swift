//
//  List+GradientButtons.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

private struct ListGradientButtons<PlusButtonView: View, MinusButtonView: View>: ViewModifier {
	let plusButton: () -> PlusButtonView
	let minusButton: () -> MinusButtonView

	func body(content: Content) -> some View {
		content
			.padding(.bottom, 25)
			.overlay(alignment: .bottom) {
				VStack(alignment: .leading, spacing: 0) {
					Divider()

					HStack(spacing: 0) {
						plusButton()

						Divider()
							.padding(.vertical, 4)

						minusButton()
					}
					.buttonStyle(.borderless)
				}
				.background(.primary.opacity(0.04))
				.fixedSize(horizontal: false, vertical: true)
			}
	}
}

extension List {
	func listGradientButtons(plusButton: @escaping () -> some View, minusButton: @escaping () -> some View) -> some View {
		self.modifier(ListGradientButtons(plusButton: plusButton, minusButton: minusButton))
	}
}
