//
//  ErrorDetailPanel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2026-03-11.
//  Copyright © 2026 Shopify. All rights reserved.
//

import AppKit

/// A panel that displays technical error details in a scrollable,
/// selectable text view. Intended to be shown from an alert's
/// "Show Details" button.
final class ErrorDetailPanel: NSPanel {
	init(detail: String) {
		super.init(
			contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable],
			backing: .buffered,
			defer: true
		)

		title = "Error Details"
		isReleasedWhenClosed = false
		isFloatingPanel = true
		hidesOnDeactivate = false
		minSize = NSSize(width: 300, height: 150)

		standardWindowButton(.zoomButton)?.isHidden = true

		let scrollView = NSTextView.scrollableTextView()
		scrollView.frame = contentView!.bounds
		scrollView.autoresizingMask = [.width, .height]

		let textView = scrollView.documentView as! NSTextView
		textView.isEditable = false
		textView.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
		textView.string = detail
		textView.textContainerInset = NSSize(width: 8, height: 8)

		contentView?.addSubview(scrollView)
	}
}
