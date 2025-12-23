//
//  FloatingPanelViewModifier.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

private struct FloatingPanelViewModifier<PanelContent: View>: ViewModifier {
	@State private var panel: FloatingPanel<PanelContent>?

	@Binding private var isPresented: Bool
	private let isPersistent: Bool
	private let panelContent: () -> PanelContent

	init(isPresented: Binding<Bool>, isPersistent: Bool = false, @ViewBuilder content: @escaping () -> PanelContent) {
		self._isPresented = isPresented
		self.isPersistent = isPersistent
		self.panelContent = content
	}

	func body(content: Content) -> some View {
		content
			.onAppear {
				panel = FloatingPanel(isPresented: $isPresented, isPersistent: isPersistent, content: panelContent)

				if isPresented {
					present()
				}
			}
			.onDisappear {
				panel?.close()
				panel = nil
			}
			.onChange(of: isPresented) { _, newValue in
				if newValue {
					present()
				} else {
					panel?.close()
				}
			}
	}

	private func present() {
		panel?.center()
		panel?.makeKeyAndOrderFront(nil)
	}
}

extension View {
	func floatingPanel<Content: View>(
		isPresented: Binding<Bool>,
		isPersistent: Bool = false,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		self.modifier(FloatingPanelViewModifier(isPresented: isPresented, isPersistent: isPersistent, content: content))
	}
}
