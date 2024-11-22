//
//  SymbolChip.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

private enum Symbol {
	case system(name: String)
	case custom(name: String)
}

struct SymbolChip: View {
	private let symbol: Symbol
	private let color: Color

	init(systemName: String, color: Color) {
		self.symbol = .system(name: systemName)
		self.color = color
	}

	init(_ name: String, color: Color) {
		self.symbol = .custom(name: name)
		self.color = color
	}

	var body: some View {
		RoundedRectangle(cornerRadius: 6, style: .continuous)
			.fill(color.gradient)
			.frame(width: 26, height: 26)
			.shadow(color: .black.opacity(0.2), radius: 0.5, x: 0, y: 0.5)
			.overlay {
				Group {
					switch symbol {
						case .system(let name):
							Image(systemName: name)
						case .custom(let name):
							Image(name)
					}
				}
				.foregroundColor(.white)
			}
	}
}
