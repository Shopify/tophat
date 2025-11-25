//
//  Theme.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

enum Theme {
	enum Size {
		private static let shouldUseGlassEffects = {
			if #available(macOS 26.0, *) {
				true
			} else {
				false
			}
		}()

		static let menuMargin: CGFloat = shouldUseGlassEffects ? 7 : 5
		static let menuItemSpacing: CGFloat = menuMargin - (shouldUseGlassEffects ? 2 : 0)
		static let menuPaddingHorizontal: CGFloat = shouldUseGlassEffects ? 7 : 9
		static let menuInsetHorizontal: CGFloat = menuMargin + menuPaddingHorizontal
		static let menuPaddingVertical: CGFloat = 3
		static let menuInsetVertical: CGFloat = menuMargin + menuPaddingVertical

		static let hairlineWidth: CGFloat = 0.5
		static let panelCornerRadius: CGFloat = shouldUseGlassEffects ? 14 : 10
	}
}
