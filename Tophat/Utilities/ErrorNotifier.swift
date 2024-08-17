//
//  ErrorNotifier.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import AppKit
import TophatFoundation

final class ErrorNotifier {
	func notify(error: Error) {
		let localizedError = error as? LocalizedError
		let styledError = error as? StyledAlertError

		alertInBackground(
			title: localizedError?.errorDescription,
			style: styledError?.alertStyle,
			content: [localizedError?.failureReason, localizedError?.recoverySuggestion].joinedWithSpaces()
		)
	}

	private func alertInBackground(title: String?, style: NSAlert.Style?, content: String) {
		let contentIsEmpty = content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

		Task.detached {
			await Notifications.alert(
				title: title ?? "An unexpected error has occurred",
				content: contentIsEmpty ? "The application could not be installed due to an unexpected error. Please try again." : content,
				style: style ?? .critical,
				buttonText: "Dismiss"
			)
		}
	}
}
