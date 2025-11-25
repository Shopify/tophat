//
//  FloatingPanel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit
import SwiftUI
import VisualEffects

final class FloatingPanel<Content: View>: NSPanel, CustomWindowPresentation {
	@Binding var isPresented: Bool
	private let isPersistent: Bool
	private let rootView: () -> Content

	private lazy var hostingView: NSHostingView<some View> = {
		let view = NSHostingView(
			rootView: rootView()
				.modifier(BackgroundViewModifier())
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

		if #available(macOS 26.0, *) {
			backgroundColor = .clear
		}

		animationBehavior = .none
		collectionBehavior = [.auxiliary, .stationary, .moveToActiveSpace, .fullScreenAuxiliary]

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

private struct BackgroundViewModifier: ViewModifier {
	func body(content: Content) -> some View {
		if #available(macOS 26.0, *) {
			content
				.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
		} else {
			content
				.background(
					VisualEffectBlur(
						material: .popover,
						blendingMode: .behindWindow,
						state: .active
					)
				)
		}
	}
}
