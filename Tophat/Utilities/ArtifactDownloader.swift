//
//  ArtifactDownloader.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-05.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import Logging

final class ArtifactDownloader: Sendable {
	private let artifactRetrievalCoordinator: ArtifactRetrievalCoordinating

	init(artifactRetrievalCoordinator: ArtifactRetrievalCoordinating) {
		self.artifactRetrievalCoordinator = artifactRetrievalCoordinator
	}

	func download(from source: ArtifactSource, to container: ArtifactContainer) async throws {
		switch source {
			case .artifactProvider(let metadata):
				try await validateHostTrustIfNeeded(metadata: metadata)

				log.info("[ArtifactDownloader] Downloading artifact from artifact provider", metadata: metadata.loggerMetadata)
				let fileURL = try await artifactRetrievalCoordinator.retrieve(metadata: metadata)
				log.info("The artifact provider has made the artifact available at \(fileURL)")

				log.info("[ArtifactDownloader] Adding downloaded artifact to container with identifier \(container.id)")
				try await container.addCopy(of: .rawDownload(fileURL))

				log.info("[ArtifactDownloader] Notifying artifact provider with identifier \(metadata.id) to clean up temporary files")
				try await artifactRetrievalCoordinator.cleanUp(artifactProviderID: metadata.id, localURL: fileURL)

			case .file(let fileURL):
				log.info("[ArtifactDownloader] Adding downloaded artifact to container with identifier \(container.id)")
				try await container.addCopy(of: .rawDownload(fileURL))
		}
	}

	private func validateHostTrustIfNeeded(metadata: ArtifactProviderMetadata) async throws {
		guard metadata.id == "http" else {
			return
		}

		log.info("[ArtifactDownloader] Built-in HTTP artifact provider detected. Validating trust.")

		guard
			let urlParameter = metadata.parameters["url"],
			let url = URL(string: urlParameter),
			let host = url.host()
		else {
			throw ArtifactDownloaderError.untrustedHost
		}

		guard await TrustedHostAlert().requestTrust(for: host) == .allow else {
			throw ArtifactDownloaderError.untrustedHost
		}
	}
}

private extension ArtifactProviderMetadata {
	var loggerMetadata: Logger.Metadata {
		[
			"id": .string(id),
			"parameters": .dictionary(parameters.mapValues { .string($0) })
		]
	}
}
