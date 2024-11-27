//
//  NSError+Extensions.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-11-27.
//

import Foundation

extension NSError {
	convenience init(embeddingLocalizedDescriptionsFrom error: Error) {
		let nsError = error as NSError
		var newUserInfo = nsError.userInfo

		if let localizedError = error as? LocalizedError {
			newUserInfo["errorDescription"] = localizedError.errorDescription
			newUserInfo["failureReason"] = localizedError.failureReason
			newUserInfo["recoverySuggestion"] = localizedError.recoverySuggestion
			newUserInfo["helpAnchor"] = localizedError.helpAnchor
		}

		self.init(domain: nsError.domain, code: nsError.code, userInfo: newUserInfo)
	}
}
