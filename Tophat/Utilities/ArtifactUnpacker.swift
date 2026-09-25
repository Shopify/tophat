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
			guard artifactURL.isDirectory else {
				throw ArtifactUnpackerError.unknownFileFormat
			}

			guard let enclosedArtifactURL = try findSupportedArtifact(in: artifactURL) else {
				throw ArtifactUnpackerError.unknownFileFormat
			}

			return try unpack(artifactURL: enclosedArtifactURL)
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

	/// Recursively searches a directory tree for the first file or directory matching a supported
	/// artifact format, such as when an application bundle is nested within intermediate build
	/// output directories (e.g. an Xcode Cloud build products archive).
	///
	/// Directories that themselves match a supported format are treated as leaves and are not
	/// searched any further.
	private func findSupportedArtifact(in directoryURL: URL) throws -> URL? {
		let supportedPathExtensions = ArtifactFileFormat.allCases.map(\.pathExtension)

		let enclosedFileURLs = try FileManager.default.contentsOfDirectory(
			at: directoryURL,
			includingPropertiesForKeys: [.isDirectoryKey]
		)

		if let match = enclosedFileURLs.first(where: { supportedPathExtensions.contains($0.pathExtension) }) {
			return match
		}

		// Descend in a stable order so that an archive containing more than one nested
		// artifact resolves to the same one every time.
		for fileURL in enclosedFileURLs.sorted(using: KeyPathComparator(\.path)) where fileURL.isDirectory {
			if let match = try findSupportedArtifact(in: fileURL) {
				return match
			}
		}

		return nil
	}

	private func extractArtifact(at url: URL) throws -> URL {
		let archive = try Archive(url: url, accessMode: .read)

		// Since application bundles are directories, avoid creating invalid
		// bundles if the destination directory would happen to end in ".app"
		let isDirectlyArchivedApplicationBundle = archive["Info.plist"] != nil
		let destinationFileName = isDirectlyArchivedApplicationBundle ? url.fileName : url.fileRoot
		let destinationURL = url.deletingLastPathComponent().appending(path: destinationFileName)

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

	var fileRoot: String {
		lastPathComponent.components(separatedBy: ".").first ?? lastPathComponent
	}
}

enum ArtifactUnpackerError: Error {
	case unknownFileFormat
	case artifactNotAvailable
	case failedToLocateBundleInAppStorePackage
}
