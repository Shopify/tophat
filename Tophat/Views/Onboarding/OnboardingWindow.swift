//
//  OnboardingWindow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit
import SwiftUI

final class OnboardingWindow<Content: View>: NSPanel, CustomWindowPresentation {
	private let rootView: () -> Content

	private lazy var hostingView: NSHostingView<some View> = {
		let view = NSHostingView(
			rootView: rootView()
				.environment(\.customWindowPresentation, self)
				.edgesIgnoringSafeArea(.all)
				// Compensate for extra height from hidden title bar.
				.padding(.top, -titleBarHeight)
		)

		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	init(content: @escaping () -> Content) {
		self.rootView = content

		super.init(
			contentRect: CGRect(x: 0, y: 0, width: 100, height: 100),
			styleMask: [.titled, .fullSizeContentView],
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

		standardWindowButton(.closeButton)?.isHidden = true
		standardWindowButton(.miniaturizeButton)?.isHidden = true
		standardWindowButton(.zoomButton)?.isHidden = true

		contentView = hostingView
		setContentSize(hostingView.intrinsicContentSize)
	}

	private var titleBarHeight: CGFloat {
		if let windowFrameHeight = contentView?.frame.height {
			return windowFrameHeight - contentLayoutRect.height
		}

		return 0
	}

	override var canBecomeKey: Bool {
		return true
	}

	override var canBecomeMain: Bool {
		return true
	}

	func dismiss() {
		close()
	}
}
