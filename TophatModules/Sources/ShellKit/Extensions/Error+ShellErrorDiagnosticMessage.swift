//
//  Error+ShellErrorDiagnosticMessage.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2026-03-11.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

public extension Error {
	/// The shell error diagnostic message if this error is a ``ShellError``, otherwise `nil`.
	var shellErrorDiagnosticMessage: String? {
		guard let shellError = self as? ShellError else {
			return nil
		}

		let trimmed = shellError.message.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? nil : trimmed
	}
}
