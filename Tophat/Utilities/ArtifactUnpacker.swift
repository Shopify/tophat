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
				let extractedURL = try extractArtifact(at: artifactURL, examineContents: true)
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

	/// Examine the artifact contents for shallowly nested supported formats.
	private func examineArtifactContents(at destinationURL: URL) throws -> URL {
		func hasNestedInfoPlist(at url: URL) -> Bool {
			let infoPlistURL = url.appendingPathComponent("Info.plist")
			return FileManager.default.isReadableFile(atPath: infoPlistURL.path)
		}

		log.info("Examining artifact contents at \(destinationURL)")

		var isDirectory: ObjCBool = false
		FileManager.default.fileExists(atPath: destinationURL.path, isDirectory: &isDirectory)

		if isDirectory.boolValue {
			if hasNestedInfoPlist(at: destinationURL) {
				// The extraction was likely an app bundle without any additional nesting.
				return destinationURL
			}

			for url in try FileManager.default.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil) {
				if let fileFormat = ArtifactFileFormat(pathExtension: url.pathExtension) {
					log.info("Nested \(fileFormat) artifact detected")
					switch fileFormat {
					case .applicationBundle:
						if hasNestedInfoPlist(at: url) {
							// This is likely a nested app bundle.
							return url
						}

					case .appStorePackage, .androidPackage:
						return url

					case .zip:
						// Intentionally ignore nested zip files.
						break
					}
				}
			}

			// No known artifacts were detected.
			throw ArtifactUnpackerError.unknownFileFormat
		} else {
			// Only a single file was extracted, no need for further examination.
			return destinationURL
		}
	}

	private func extractArtifact(at url: URL, examineContents: Bool = false) throws -> URL {
		let destinationURL = url.deletingLastPathComponent().appending(path: url.fileName)

		log.info("Uncompressing artifact at \(url)")
		try FileManager.default.unzipItem(at: url, to: destinationURL)

		let finalURL: URL = examineContents ? try examineArtifactContents(at: destinationURL) : destinationURL
		log.info("Artifact uncompressed to \(finalURL)")

		return finalURL
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
