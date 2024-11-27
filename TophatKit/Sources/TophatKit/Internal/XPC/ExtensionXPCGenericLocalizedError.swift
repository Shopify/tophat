//
//  ExtensionXPCGenericLocalizedError.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-11-27.
//

import Foundation

struct ExtensionXPCGenericLocalizedError: LocalizedError {
	let errorDescription: String?
	let failureReason: String?
	let recoverySuggestion: String?
	let helpAnchor: String?

	init?(nsError: NSError) {
		let userInfo = nsError.userInfo

		self.errorDescription = userInfo["errorDescription"] as? String
		self.failureReason = userInfo["failureReason"] as? String
		self.recoverySuggestion = userInfo["recoverySuggestion"] as? String
		self.helpAnchor = userInfo["helpAnchor"] as? String

		guard errorDescription != nil || failureReason != nil || recoverySuggestion != nil || helpAnchor != nil else {
			return nil
		}
	}
}
