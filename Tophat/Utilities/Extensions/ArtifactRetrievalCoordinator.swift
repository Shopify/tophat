//
//  ExtensionHost.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import ExtensionFoundation
import TophatFoundation
@_spi(TophatKitInternal) import TophatKit

protocol AppExtensionIdentityResolving: Sendable {
	func identity(artifactProviderID: String) async -> AppExtensionIdentity?
}

extension ExtensionHost: AppExtensionIdentityResolving {
	func identity(artifactProviderID: String) async -> AppExtensionIdentity? {
		let extensionWithIdentity = availableExtensions.first { availableExtension in
			availableExtension.specification.artifactProviders.contains { $0.id == artifactProviderID }
		}

		guard let extensionWithIdentity else {
			return nil
		}

		return extensionWithIdentity.identity
	}
}

protocol ArtifactRetrievalCoordinating: Sendable {
	func retrieve(metadata: ArtifactProviderMetadata) async throws -> URL
	func cleanUp(artifactProviderID: String, localURL: URL) async throws
}

struct ArtifactRetrievalCoordinator {
	private let appExtensionIdentityResolver: AppExtensionIdentityResolving

	init(appExtensionIdentityResolver: AppExtensionIdentityResolving) {
		self.appExtensionIdentityResolver = appExtensionIdentityResolver
	}
}

extension ArtifactRetrievalCoordinator: ArtifactRetrievalCoordinating {
	func retrieve(metadata: ArtifactProviderMetadata) async throws -> URL {
		guard let artifactProvidingExtension = await appExtensionIdentityResolver.identity(artifactProviderID: metadata.id) else {
			throw ArtifactRetrievalCoordinatorError.artifactProviderNotFound(id: metadata.id)
		}

		return try await artifactProvidingExtension.withXPCSession { session in
			let message = RetrieveArtifactMessage(
				providerID: metadata.id,
				parameters: metadata.parameters
			)

			let result = try await session.send(message)
			return result.localURL
		}
	}

	func cleanUp(artifactProviderID: String, localURL: URL) async throws {
		guard let artifactProvidingExtension = await appExtensionIdentityResolver.identity(artifactProviderID: artifactProviderID) else {
			throw ArtifactRetrievalCoordinatorError.artifactProviderNotFound(id: artifactProviderID)
		}

		try await artifactProvidingExtension.withXPCSession { session in
			let message = CleanUpArtifactMessage(providerID: artifactProviderID, url: localURL)
			try await session.send(message)
		}
	}
}

enum ArtifactRetrievalCoordinatorError: Error {
	case artifactProviderNotFound(id: String)
}
