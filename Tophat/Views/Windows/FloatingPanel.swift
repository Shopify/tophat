//
//  FloatingPanel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit
import SwiftUI

final class FloatingPanel<Content: View>: NSPanel, CustomWindowPresentation {
	@Binding var isPresented: Bool
	private let isPersistent: Bool
	private let rootView: () -> Content

	private lazy var visualEffectView: NSVisualEffectView = {
		let view = NSVisualEffectView()
		view.blendingMode = .behindWindow
		view.state = .active
		view.material = .popover
		view.translatesAutoresizingMaskIntoConstraints = true
		return view
	}()

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

	init(isPresented: Binding<Bool>, isPersistent: Bool = false, content: @escaping () -> Content) {
		self._isPresented = isPresented
		self.isPersistent = isPersistent
		self.rootView = content

		super.init(
			contentRect: CGRect(x: 0, y: 0, width: 100, height: 100),
			styleMask: [.titled, .nonactivatingPanel, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)

		isMovable = isPersistent
		isMovableByWindowBackground = isPersistent
		isFloatingPanel = true
		level = .floating
		isOpaque = false
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		hidesOnDeactivate = !isPersistent

		animationBehavior = .none
		collectionBehavior = [.auxiliary, .stationary, .moveToActiveSpace, .fullScreenAuxiliary]

		standardWindowButton(.closeButton)?.isHidden = true
		standardWindowButton(.miniaturizeButton)?.isHidden = true
		standardWindowButton(.zoomButton)?.isHidden = true

		contentView = visualEffectView
		visualEffectView.addSubview(hostingView)
		setContentSize(hostingView.intrinsicContentSize)

		NSLayoutConstraint.activate([
			hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
			hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
			hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
			hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor)
		])
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

	override func resignMain() {
		super.resignMain()
		if !isPersistent {
			close()
		}
	}

	override func close() {
		super.close()
		isPresented = false
	}

	func dismiss() {
		close()
	}
}
