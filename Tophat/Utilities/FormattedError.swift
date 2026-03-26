//
//  FormattedError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2026-03-09.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

struct FormattedError: CustomStringConvertible {
	let title: String
	let detail: String

	var description: String {
		let punctuatedTitle = title.last?.isPunctuation == true ? title : "\(title)."
		return "\(punctuatedTitle) \(detail)"
	}

	init(_ error: Error) {
		let localizedError = error as? LocalizedError

		self.title = localizedError?.errorDescription ?? "An error occurred."

		let content = [localizedError?.failureReason, localizedError?.recoverySuggestion].joinedWithSpaces()
		let contentIsEmpty = content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

		self.detail = contentIsEmpty
			? "Tophat wasn’t able to identify the cause. Please try again."
			: content
	}
}
