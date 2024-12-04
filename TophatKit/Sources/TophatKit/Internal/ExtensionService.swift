//
//  ExtensionService.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-08.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

struct ExtensionService: Sendable {
	private let appExtension: any TophatExtension

	init(appExtension: some TophatExtension) {
		self.appExtension = appExtension
	}

	func handleRetreiveArtifact(message: RetrieveArtifactMessage) async throws -> RetrieveArtifactMessage.Reply {
		guard let artifactProvider = makeArtifactProvider(id: message.providerID) else {
			throw RetreiveArtifactError.noArtifactProviders
		}

		try artifactProvider.setParameters(to: message.parameters)

		guard let resultContainer = try await artifactProvider.retrieve() as? ArtifactProviderResultContainer else {
			throw RetreiveArtifactError.invalidResult
		}

		return resultContainer
	}

	func handleExtensionDescriptor(message: FetchExtensionSpecificationMessage) -> FetchExtensionSpecificationMessage.Reply {
		ExtensionSpecification(provider: appExtension)
	}

	func handleCleanUp(message: CleanUpArtifactMessage) async throws {
		guard let artifactProvider = makeArtifactProvider(id: message.providerID) else {
			throw RetreiveArtifactError.noArtifactProviders
		}

		try await artifactProvider.cleanUp(localURL: message.url)
	}

	private func makeArtifactProvider(id: String) -> (any ArtifactProvider)? {
		guard
			let artifactProviding = appExtension as? any ArtifactProviding,
			let artifactProviders = type(of: artifactProviding).artifactProviders.arrayValue,
			let firstMatchingArtifactProvider = artifactProviders.first(where: { type(of: $0).id == id })
		else {
			return nil
		}

		return type(of: firstMatchingArtifactProvider).init()
	}
}

enum RetreiveArtifactError: Error {
	case noArtifactProviders
	case invalidResult
}
