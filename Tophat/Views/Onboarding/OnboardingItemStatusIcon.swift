//
//  OnboardingItemStatusIcon.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct OnboardingItemStatusIcon<Content: View>: View {
	@State private var popoverPresented = false

	private let status: OnboardingItemStatus
	private let content: () -> Content?

	init(status: OnboardingItemStatus, @ViewBuilder content: @escaping () -> Content? = { EmptyView() }) {
		self.status = status
		self.content = content
	}

	var body: some View {
		Group {
			switch status {
				case .complete:
					Image(systemName: "checkmark.circle")
						.font(.title2)
						.foregroundColor(.green)

				case .incomplete:
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
				case .indeterminate:
					ProgressView()
						.progressViewStyle(.circular)
						.controlSize(.small)
			}
		}
		.frame(minWidth: 20, minHeight: 20, alignment: .center)
		.padding(.trailing, 6)
	}
}
