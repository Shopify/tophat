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
			alert.messageText = "The host “\(host)” has not been trusted. Are you sure you want to continue?"
			alert.informativeText = "Launching an application containing malicious code can harm your Mac or compromise your privacy. Be sure you trust the origin of this application before continuing."

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
