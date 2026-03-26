//
//  TrustedHostAlert.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-08-26.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

@MainActor final class TrustedHostAlert {
	@CodableAppStorage("TrustedHosts") private var trustedHosts: [String] = []

	func requestTrust(for host: String) async -> HostTrustResult {
		if trustedHosts.contains(host) {
			return .allow
		}

		let result = await MainActor.run {
			NSApp.activate(ignoringOtherApps: true)

			let alert = NSAlert()
			alert.alertStyle = .critical
			alert.messageText = "The host “\(host)” hasn’t been trusted."
			alert.informativeText = "Downloading an app from an untrusted host could harm your devices or compromise your privacy."

			let trustButton = alert.addButton(withTitle: "Trust")
			trustButton.keyEquivalent = ""

			let cancelButton = alert.addButton(withTitle: "Cancel")
			cancelButton.keyEquivalent = "\r"

			return alert.runModal()
		}

		switch result {
		case .alertFirstButtonReturn:
			trustedHosts.append(host)
			return .allow
		default:
			return .block
		}
	}
}
