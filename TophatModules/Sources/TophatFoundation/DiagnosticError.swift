//
//  DiagnosticError.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2026-03-11.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

/// The type you use to wrap an error in order to provide additional technical details
/// for debugging purposes.
public struct DiagnosticError: Error {
	/// The error to present to the user.
	public let error: Error

	/// A technical description of the underlying cause.
	public let technicalDetails: String?

	public init(_ error: Error, technicalDetails: String? = nil) {
		self.error = error
		self.technicalDetails = technicalDetails
	}
}

extension DiagnosticError: LocalizedError {
	public var errorDescription: String? {
		(error as? LocalizedError)?.errorDescription
	}

	public var failureReason: String? {
		(error as? LocalizedError)?.failureReason
	}

	public var recoverySuggestion: String? {
		(error as? LocalizedError)?.recoverySuggestion
	}
}
