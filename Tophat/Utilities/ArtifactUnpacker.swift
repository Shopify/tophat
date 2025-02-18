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

	private func zipArtifactApplicationBundleRoot(at url: URL) throws -> String? {
		let archive = try Archive(url: url, accessMode: .read)
		// Find the "Info.plist" archive entry that is nearest to the root of the archive.
		let shallowestInfoPlistEntry = archive
			.filter { $0.path.hasSuffix("Info.plist") }
			.min(by: { $0.path.count { $0 == "/" } < $1.path.count { $0 == "/" } })
		if let entry = shallowestInfoPlistEntry, entry.path.contains("/") {
			// It is located at least one directory deep, assume that this is the application bundle root.
			let parentPath = (entry.path as NSString).deletingLastPathComponent
			if archive[parentPath + "/"] != nil {
				return parentPath
			}
		}

		// If there are no "Info.plist" files, or one is already in the root, there is nothing to do.
		return nil
	}

	private func extractArtifact(at url: URL) throws -> URL {
		let destinationURL = url.deletingLastPathComponent().appending(path: url.fileName)

		log.info("Uncompressing artifact at \(url)")
		try FileManager.default.unzipItem(at: url, to: destinationURL)

		if let appBundleRoot = try? zipArtifactApplicationBundleRoot(at: url) {
			log.info("Nested application bundle detected")
			// Move the original destination to "_tmp", then move the nested app bundle to the destination.
			let workingDestinationURL = url.deletingLastPathComponent().appending(path: "_tmp")
			try FileManager.default.moveItem(at: destinationURL, to: workingDestinationURL)
			let nestedAppBundleRootURL = workingDestinationURL.appending(path: appBundleRoot)
			try FileManager.default.moveItem(at: nestedAppBundleRootURL, to: destinationURL)
		}

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
