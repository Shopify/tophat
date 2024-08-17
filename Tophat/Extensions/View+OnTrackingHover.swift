//
//  View+OnTrackingHover.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

extension View {
	/// Adds an action to perform when the user moves the pointer over or away from the view’s frame.
	///
	/// This is similar to SwiftUI's built-in `onHover` but uses `NSTrackingArea` under the hood
	/// which doesn't experience some of the bugs that `onHover` does, particularly with states
	/// occasionally getting stuck when the mouse leaves the view's frame in some circumstances.
	/// - Parameter perform: The action to perform whenever the pointer enters or exits this view’s frame.
	/// - Returns: A view that triggers action when the pointer enters or exits this view’s frame.
	func onTrackingHover(perform: @escaping (Bool) -> Void) -> some View {
		modifier(TrackingModifier(onHover: perform))
	}
}

private struct TrackingModifier: ViewModifier {
	let onHover: (Bool) -> Void

	func body(content: Content) -> some View {
		content.background(TrackingView(onHover: onHover))
	}

	private struct TrackingView: NSViewRepresentable {
		let onHover: (Bool) -> Void

		func makeCoordinator() -> Coordinator {
			let coordinator = Coordinator(onHover: onHover)
			return coordinator
		}

		class Coordinator: NSResponder {
			private let onHover: (Bool) -> Void

			init(onHover: @escaping (Bool) -> Void) {
				self.onHover = onHover
				super.init()
			}

			required init?(coder: NSCoder) {
				fatalError("init(coder:) has not been implemented")
			}

			override func mouseEntered(with event: NSEvent) {
				onHover(true)
			}

			override func mouseExited(with event: NSEvent) {
				onHover(false)
			}
		}

		func makeNSView(context: Context) -> NSView {
			let view = NSView(frame: .zero)

			let options: NSTrackingArea.Options = [
				.mouseEnteredAndExited,
				.inVisibleRect,
				.activeInKeyWindow
			]

			let trackingArea = NSTrackingArea(
				rect: view.frame,
				options: options,
				owner: context.coordinator,
				userInfo: nil
			)

			view.addTrackingArea(trackingArea)

			return view
		}

		func updateNSView(_ nsView: NSView, context: Context) {}

		static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
			nsView.trackingAreas.forEach { nsView.removeTrackingArea($0) }
		}
	}
}
