//
//  AboutWindowViewModifier.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

private struct AboutWindowViewModifier<WindowContent: View>: ViewModifier {
	@State private var window: AboutWindow<WindowContent>?

	@Binding private var isPresented: Bool
	private let windowContent: () -> WindowContent

	init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> WindowContent) {
		self._isPresented = isPresented
		self.windowContent = content
	}

	func body(content: Content) -> some View {
		content
			.onAppear {
				window = AboutWindow(isPresented: $isPresented, content: windowContent)

				if isPresented {
					present()
				}
			}
			.onDisappear {
				window?.close()
				window = nil
			}
			.onChange(of: isPresented) { _, newValue in
				if newValue {
					present()
				} else {
					window?.close()
				}
			}
	}

	private func present() {
		window?.center()
		window?.makeKeyAndOrderFront(nil)
	}
}

extension View {
	func aboutWindow<Content: View>(
		isPresented: Binding<Bool>,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		self.modifier(AboutWindowViewModifier(isPresented: isPresented, content: content))
	}
}
