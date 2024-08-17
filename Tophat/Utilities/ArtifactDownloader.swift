//
//  ArtifactDownloader.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-25.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import GoogleStorageKit
import AsyncAlgorithms

final class ArtifactDownloader: NSObject {
	private let downloadsDirectory = FileManager.default.temporaryDirectory.appending(paths: ["com.shopify.tophat", "downloads"])

	let progressUpdates = AsyncChannel<TaskProgress>()

	fileprivate var progressObservation: NSKeyValueObservation?

	/// Downloads and extracts an artifact and returns the build.
	/// - Parameter artifact: The artifact to download.
	/// - Returns: The downloaded build derived from the artifact.
	func download(artifactUrl: URL) async throws -> URL {
		let temporaryDirectory = try createTemporaryDirectory()
		let destinationURL = temporaryDirectory.appending(path: artifactUrl.lastPathComponent)

		if artifactUrl.isFileURL {
			try FileManager.default.copyItem(at: artifactUrl, to: destinationURL)
		} else if artifactUrl.isGoogleStorageURL {
			for try await progress in try GoogleStorage.download(artifactURL: artifactUrl, to: destinationURL) {
				let progress: TaskProgress = .determinate(
					totalUnitCount: progress.totalUnitCount,
					pendingUnitCount: progress.pendingUnitCount
				)

				await progressUpdates.send(progress)
			}
		} else {
			try await downloadFile(url: artifactUrl, to: destinationURL)
		}

		return destinationURL
	}

	private func downloadFile(url: URL, to destinationURL: URL) async throws {
		do {
			defer { progressObservation = nil }

			let (localURL, _) = try await URLSession.shared.download(from: url, delegate: self)
			try FileManager.default.moveItem(at: localURL, to: destinationURL)

		} catch {
			throw ArtifactDownloaderError.failedToDownloadArtifact
		}
	}

	private func createTemporaryDirectory() throws -> URL {
		let temporaryDirectory = downloadsDirectory.appending(path: UUID().uuidString)

		do {
			try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
		} catch {
			throw ArtifactDownloaderError.failedToCreateDownloadsDirectory
		}

		return temporaryDirectory
	}
}

extension ArtifactDownloader: URLSessionTaskDelegate {
	func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
		progressObservation = task.progress.observe(\.fractionCompleted) { progress, observedChange in
			let progress: TaskProgress = .determinate(
				totalUnitCount: 1,
				pendingUnitCount: progress.fractionCompleted
			)

			Task { [weak self] in
				await self?.progressUpdates.send(progress)
			}
		}
	}
}

enum ArtifactDownloaderError: Error {
	case failedToCreateDownloadsDirectory
	case failedToDownloadArtifact
}
