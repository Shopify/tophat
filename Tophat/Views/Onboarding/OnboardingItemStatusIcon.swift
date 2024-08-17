//
//  OnboardingItemStatusIcon.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct OnboardingItemStatusIcon<Content: View>: View {
	enum Value {
		case complete
		case warning
	}

	@State private var popoverPresented = false

	private let state: Value
	private let content: () -> Content?

	init(state: Value, @ViewBuilder content: @escaping () -> Content? = { EmptyView() }) {
		self.state = state
		self.content = content
	}

	var body: some View {
		Group {
			switch state {
				case .complete:
					Image(systemName: "checkmark.circle")
						.font(.title2)
						.foregroundColor(.green)

				case .warning:
					Button {
						popoverPresented.toggle()
					} label: {
						Image(systemName: "exclamationmark.circle.fill")
							.font(.title2)
							.foregroundColor(.orange)
					}
					.buttonStyle(.plain)
					.popover(isPresented: $popoverPresented, arrowEdge: .leading) {
						content()
							.padding()
							.frame(maxWidth: 400, alignment: .topLeading)
					}
			}
		}
		.padding(.trailing, 6)
	}
}
