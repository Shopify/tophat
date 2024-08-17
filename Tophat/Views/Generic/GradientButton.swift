//
//  GradientButton.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct GradientButton: View {
	enum Style: String {
		case plus
		case minus
	}

	let style: Style
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Image(systemName: style.rawValue)
				.font(.subheadline)
				.fontWeight(.semibold)
				.frame(width: 24, height: 24)
		}
		.buttonStyle(.borderless)
	}
}
