//
//  ArtifactProvider+Parameters.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

extension ArtifactProvider {
	func setParameters(to parameterDictionary: [String: String]) throws {
		for parameter in parameters {
			let key = parameter.key

			guard let value = parameterDictionary[key] else {
				throw ArtifactProviderError.missingParameter
			}

			try parameter.store(stringRepresentation: value)
		}
	}

	var parameters: [any AnyArtifactProviderParameter] {
		Mirror(reflecting: self)
			.children
			.compactMap { child in
				child.value as? any AnyArtifactProviderParameter
			}
	}
}

private extension AnyArtifactProviderParameter {
	func store(stringRepresentation: String) throws {
		guard let parameter = self as? ArtifactProviderParameter<Value> else {
			throw ArtifactProviderError.invalidType
		}

		parameter.storage = Value(stringRepresentation: stringRepresentation)
	}
}

enum ArtifactProviderError: Error {
	case missingParameter
	case invalidType
}
