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

struct ArtifactResource: Identifiable {
	let id: UUID
	let url: URL
	let application: Application
}

final class ArtifactDownloader {
	private let artifactsURL: URL = .temporaryDirectory
		.appending(path: Bundle.main.bundleIdentifier!)
		.appending(path: "Artifacts")

	private let artifactRetrievalCoordinator: ArtifactRetrievalCoordinating

	init(artifactRetrievalCoordinator: ArtifactRetrievalCoordinating) {
		self.artifactRetrievalCoordinator = artifactRetrievalCoordinator
	}

	func download(from source: RemoteArtifactSource) async throws -> ArtifactResource {
		do {
			return try await _download(from: source)
		} catch {
			throw ArtifactDownloaderError.failedToDownloadArtifact
		}
	}

	private func _download(from source: RemoteArtifactSource) async throws -> ArtifactResource {
		let resourceID = UUID()
		let artifactDirectoryURL = artifactsURL.appending(path: resourceID.uuidString)

		try FileManager.default.createDirectory(at: artifactDirectoryURL, withIntermediateDirectories: true)

		let artifactURL: URL

		switch source {
			case .artifactProvider(let metadata):
				log.info("Downloading artifact from artifact provider", metadata: metadata.loggerMetadata)
				let localURL = try await artifactRetrievalCoordinator.retrieve(metadata: metadata)
				log.info("The artifact provider has made the artifact available at \(localURL)")

				let fileName = localURL.lastPathComponent
				let destinationURL = artifactDirectoryURL.appending(component: fileName)

				log.info("Copying downloaded artifact to \(destinationURL)")
				try FileManager.default.copyItem(at: localURL, to: destinationURL)

				log.info("Notifying artifact provider with identifier \(metadata.id) to clean up temporary files")
				try await artifactRetrievalCoordinator.cleanUp(artifactProviderID: metadata.id, localURL: localURL)

				artifactURL = destinationURL

			case .file(let fileURL):
				let fileName = fileURL.lastPathComponent
				let destinationURL = artifactDirectoryURL.appending(component: fileName)

				log.info("Copying artifact on local filesystem to \(destinationURL)")
				try FileManager.default.copyItem(at: fileURL, to: destinationURL)

				artifactURL = destinationURL
		}

		log.info("Unpacking artifact at \(artifactURL)")
		let application = try ArtifactUnpacker().unpack(artifactURL: artifactURL)

		log.info("Artifact unpacked to \(application.url)")

		return ArtifactResource(id: resourceID, url: artifactURL, application: application)
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
