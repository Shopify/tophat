//
//  SectionHeadingTextStyle.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct SectionHeadingTextStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.callout.weight(.semibold))
			.foregroundColor(.secondary)
	}
}

extension View {
	func sectionHeadingTextStyle() -> some View {
		modifier(SectionHeadingTextStyle())
	}
}
