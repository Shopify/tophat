//
//  NSApplication+ShowSettingsWindow.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit

extension NSApplication {
	func showSettingsWindow() {
		activate(ignoringOtherApps: true)
		sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
	}
}
