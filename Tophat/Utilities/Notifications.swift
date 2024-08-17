//
//  Notifications.swift
//  Tophat
//
//  Created by Jared Hendry on 2022-09-10.
//  Copyright © 2020 Shopify. All rights reserved.
//

import UserNotifications
import AppKit

enum Notifications {
	static func requestPermissions() {
		Task {
			try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
		}
	}

	static func notify(message: String) {
		Task(priority: .high) {
			let content = UNMutableNotificationContent()
			content.title = "Tophat"
			content.body = message

			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
			try await UNUserNotificationCenter.current().add(request)
		}
	}

	@MainActor
	static func alert(title: String, content: String, style: NSAlert.Style, buttonText: String) {
		NSApp.activate(ignoringOtherApps: true)

		let alert = NSAlert()
		alert.messageText = title
		alert.informativeText = content
		alert.alertStyle = style
		alert.addButton(withTitle: buttonText)
		alert.runModal()
	}
}
