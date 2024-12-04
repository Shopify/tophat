//
//  ArtifactUnpacker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-18.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import ZIPFoundation

final class ArtifactUnpacker: Sendable {
	/// Unpacks a downloaded artifact in an `ArtifactContainer` and places it in the same container.
	/// - Parameter container: The container in which the raw artifact is located and where to place the unpacked artifact.
	func unpack(downloadedItemInContainer container: ArtifactContainer) async throws {
		guard let rawDownloadURL = await container.rawDownloads.first, rawDownloadURL.isFileURL else {
			throw ArtifactUnpackerError.artifactNotAvailable
		}

		let application = try unpack(artifactURL: rawDownloadURL)
		try await container.addCopy(of: .application(application))
	}

	private func unpack(artifactURL: URL) throws -> Application {
		guard let fileFormat = ArtifactFileFormat(pathExtension: artifactURL.pathExtension) else {
			throw ArtifactUnpackerError.unknownFileFormat
		}

		switch fileFormat {
			case .zip:
				let extractedURL = try extractArtifact(at: artifactURL)
				return try unpack(artifactURL: extractedURL)

			case .appStorePackage:
				let extractedURL = try extractAppStorePackage(at: artifactURL)
				return AppleApplication(bundleURL: extractedURL, appStorePackageURL: artifactURL)

			case .applicationBundle:
				return AppleApplication(bundleURL: artifactURL)

			case .androidPackage:
				return AndroidApplication(url: artifactURL)
		}
	}

	private func extractAppStorePackage(at url: URL) throws -> URL {
		let extractedPath = try extractArtifact(at: url)

		let fileURLs = try FileManager.default.contentsOfDirectory(
			at: extractedPath.appending(path: "Payload"),
			includingPropertiesForKeys: nil
		)

		guard let fileURL = fileURLs.first(where: { $0.pathExtension == ArtifactFileFormat.applicationBundle.pathExtension }) else {
			throw ArtifactUnpackerError.failedToLocateBundleInAppStorePackage
		}

		return fileURL
	}

	private func extractArtifact(at url: URL) throws -> URL {
		let destinationURL = url.deletingLastPathComponent().appending(path: url.fileName)

		log.info("Uncompressing artifact at \(url)")
		try FileManager.default.unzipItem(at: url, to: destinationURL)
		log.info("Artifact uncompressed to \(destinationURL)")

		return destinationURL
	}
}

private extension URL {
	var fileName: String {
		lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")
	}
}

enum ArtifactUnpackerError: Error {
	case unknownFileFormat
	case artifactNotAvailable
	case failedToLocateBundleInAppStorePackage
}
