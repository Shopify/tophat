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
		Task.detached {
			let styledError = error as? StyledAlertError
			let formatted = FormattedError(error)

			await Notifications.alert(
				title: formatted.title,
				content: formatted.detail,
				style: styledError?.alertStyle ?? .critical,
				buttonText: "Dismiss",
				technicalDetails: (error as? DiagnosticError)?.technicalDetails
			)
		}
	}
}
