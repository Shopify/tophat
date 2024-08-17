//
//  AboutWindow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-31.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit
import SwiftUI

final class AboutWindow<Content: View>: NSPanel {
	@Binding var isPresented: Bool
	private let rootView: () -> Content

	private lazy var hostingView: NSHostingView<some View> = {
		let view = NSHostingView(rootView: rootView())
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	init(isPresented: Binding<Bool>, content: @escaping () -> Content) {
		self._isPresented = isPresented
		self.rootView = content

		super.init(
			contentRect: CGRect(x: 0, y: 0, width: 100, height: 100),
			styleMask: [.closable, .titled, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)

		isMovable = true
		isMovableByWindowBackground = true
		isFloatingPanel = false
		isOpaque = true
		titleVisibility = .hidden
		titlebarAppearsTransparent = true

		animationBehavior = .utilityWindow
		hidesOnDeactivate = false

		contentView = hostingView
		setContentSize(hostingView.intrinsicContentSize)
	}

	override var canBecomeKey: Bool {
		return true
	}

	override var canBecomeMain: Bool {
		return true
	}

	override func close() {
		super.close()
		isPresented = false
	}
}
