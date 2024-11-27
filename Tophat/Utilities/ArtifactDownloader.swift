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

final class ArtifactDownloader {
	private let artifactRetrievalCoordinator: ArtifactRetrievalCoordinating

	init(artifactRetrievalCoordinator: ArtifactRetrievalCoordinating) {
		self.artifactRetrievalCoordinator = artifactRetrievalCoordinator
	}

	func download(from source: RemoteArtifactSource, to container: ArtifactContainer) async throws {
		switch source {
			case .artifactProvider(let metadata):
				log.info("[ArtifactDownloader] Downloading artifact from artifact provider", metadata: metadata.loggerMetadata)
				let fileURL = try await artifactRetrievalCoordinator.retrieve(metadata: metadata)
				log.info("The artifact provider has made the artifact available at \(fileURL)")

				log.info("[ArtifactDownloader] Adding downloaded artifact to container with identifier \(container.id)")
				try container.addCopy(of: .rawDownload(fileURL))

				log.info("[ArtifactDownloader] Notifying artifact provider with identifier \(metadata.id) to clean up temporary files")
				try await artifactRetrievalCoordinator.cleanUp(artifactProviderID: metadata.id, localURL: fileURL)

			case .file(let fileURL):
				log.info("[ArtifactDownloader] Adding downloaded artifact to container with identifier \(container.id)")
				try container.addCopy(of: .rawDownload(fileURL))
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

enum ArtifactDownloaderError: Error {
	case failedToDownloadArtifact
}
