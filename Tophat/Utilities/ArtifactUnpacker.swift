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
import ShellKit

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
		guard let fileFormat = ArtifactFileFormat(url: artifactURL) else {
			guard artifactURL.isDirectory else {
				throw ArtifactUnpackerError.unknownFileFormat
			}

			let enclosedFileURLs = try FileManager.default.contentsOfDirectory(
				at: artifactURL,
				includingPropertiesForKeys: nil
			)

			let firstSupportedEnclosedFileURL = enclosedFileURLs.first { fileURL in
				ArtifactFileFormat(url: fileURL) != nil
			}

			guard let firstSupportedEnclosedFileURL else {
				throw ArtifactUnpackerError.unknownFileFormat
			}

			return try unpack(artifactURL: firstSupportedEnclosedFileURL)
		}

		switch fileFormat {
			case .zip:
				let extractedURL = try extractArtifact(at: artifactURL)
				return try unpack(artifactURL: extractedURL)

			case .tarGzip:
				let extractedURL = try extractTarGzipArtifact(at: artifactURL)
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

	private func extractTarGzipArtifact(at url: URL) throws -> URL {
		// Use tar command to extract .tar.gz files
        let destinationFileName = url.deletingFullPathExtension
        let destinationURL = url.deletingLastPathComponent().appending(path: destinationFileName)

		log.info("Extracting tar.gz artifact at \(url)")

		// Create destination directory
		try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true)

		// Extract using tar command: tar -xzf <file> -C <destination>
		let tarCommand = TarCommand.extract(archiveUrl: url, destinationUrl: destinationURL)
		try run(command: tarCommand, log: log)

		log.info("Artifact extracted to \(destinationURL)")

		return destinationURL
	}
}

enum ArtifactUnpackerError: Error {
	case unknownFileFormat
	case artifactNotAvailable
	case failedToLocateBundleInAppStorePackage
}

// MARK: - Tar Command

private enum TarCommand {
	case extract(archiveUrl: URL, destinationUrl: URL)
}

extension TarCommand: ShellCommand {
	var executable: Executable {
		.name("tar")
	}

	var arguments: [String] {
		switch self {
		case .extract(let archiveUrl, let destinationUrl):
			return [
				"-xzf",
				archiveUrl.path(percentEncoded: false),
				"-C",
				destinationUrl.path(percentEncoded: false)
			]
		}
	}
}
