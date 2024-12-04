//
//  FetchExtensionSpecificationMessage.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-09.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

@_spi(TophatKitInternal)
public struct FetchExtensionSpecificationMessage: ExtensionXPCMessage {
	public typealias Reply = ExtensionSpecification

	public init() {}
}

@_spi(TophatKitInternal)
public struct ExtensionSpecification: Codable, Sendable {
	public let title: LocalizedStringResource
	public let description: LocalizedStringResource?
	public let isConfigurable: Bool
	public let artifactProviders: [ArtifactProviderSpecification]

	init(provider: some TophatExtension) {
		let providerType = type(of: provider)

		self.title = providerType.title
		self.description = providerType.description
		self.isConfigurable = provider is any SettingsProviding

		self.artifactProviders = if let artifactProviding = provider as? any ArtifactProviding {
			type(of: artifactProviding).artifactProviders.arrayValue?.map { .init(provider: $0) } ?? []
		} else {
			[]
		}
	}
}

@_spi(TophatKitInternal)
public struct ArtifactProviderSpecification: Identifiable, Codable, Sendable {
	public let id: String
	public let title: LocalizedStringResource
	public let parameters: [ArtifactProviderParameterSpecification]

	init(provider: some ArtifactProvider) {
		let providerType = type(of: provider)

		self.id = providerType.id
		self.title = providerType.title
		self.parameters = provider.parameters.map { .init(parameter: $0) }
	}
}

@_spi(TophatKitInternal)
public struct ArtifactProviderParameterSpecification: Codable, Sendable {
	public let key: String
	public let title: LocalizedStringResource
	public let description: LocalizedStringResource?
	public let prompt: LocalizedStringResource?
	public let help: LocalizedStringResource?
	public let isOptional: Bool

	init(parameter: some AnyArtifactProviderParameter) {
		self.key = parameter.key
		self.title = parameter.title
		self.description = parameter.description
		self.prompt = parameter.prompt
		self.help = parameter.help
		self.isOptional = parameter.isOptional
	}
}
