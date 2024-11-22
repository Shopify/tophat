//
//  ArtifactProviderParameter.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

@propertyWrapper
public final class ArtifactProviderParameter<Value>: @unchecked Sendable where Value: ArtifactProviderValue, Value: Sendable {
	public let key: String
	public let title: LocalizedStringResource
	public let description: LocalizedStringResource?
	public let prompt: LocalizedStringResource?
	public let help: LocalizedStringResource?

	var storage: Value?

	public var wrappedValue: Value {
		get {
			if let storage { return storage }
			fatalError("Attempting to access parameter value before initialization!")
		}
		set {
			storage = newValue
		}
	}

	public init(
		key: String,
		title: LocalizedStringResource,
		description: LocalizedStringResource? = nil,
		prompt: LocalizedStringResource? = nil,
		help: LocalizedStringResource? = nil
	) {
		self.key = key
		self.title = title
		self.description = description
		self.prompt = prompt
		self.help = help
	}
}

extension ArtifactProviderParameter: AnyArtifactProviderParameter {}
