//
//  CachingApplicationDownloader.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-26.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

/// The class you use to perform the full download process of an artifact in order to
/// have access to the associated application locally.
///
/// During the lifetime of an instance of this class, any requests are cached based on the
/// sources provided.  A subsequent request with the exact same source value is considered
/// will either wait for an existing request or return a completed one.
actor CachingApplicationDownloader: ApplicationDownloading {
	private let artifactDownloader: ArtifactDownloader
	private let artifactUnpacker: ArtifactUnpacker
	private let taskStatusReporter: TaskStatusReporter

	private var downloads: [RemoteArtifactSource: Download] = [:]
	private var clearCacheTask: Task<(), Error>?

	init(
		artifactDownloader: ArtifactDownloader,
		artifactUnpacker: ArtifactUnpacker,
		taskStatusReporter: TaskStatusReporter
	) {
		self.artifactDownloader = artifactDownloader
		self.artifactUnpacker = artifactUnpacker
		self.taskStatusReporter = taskStatusReporter
	}

	/// Downloads an application found in the artifact retreivable using a `RemoteArtifactSource`. If a
	/// download is in progress, this function will wait for the existing download.
	///
	/// - Parameter source: The source of the remote artifact to download.
	/// - Returns: An application.
	func download(from source: RemoteArtifactSource, context: OperationContext? = nil) async throws -> Application {
		if let clearCacheTask {
			// Wait if the cache is being cleared.
			_ = await clearCacheTask.result
		}

		if let existingDownload = downloads[source] {
			return try await existingDownload.task.value
		}

		let container = ArtifactContainer()

		let task = Task {
			let taskStatus = TaskStatus(
				displayName: "Fetching \(context?.appName ?? "App")",
				initialState: .running(message: "Downloading", progress: .indeterminate)
			)

			await taskStatusReporter.add(status: taskStatus)

			defer {
				Task { await taskStatus.markAsDone() }
			}

			try await artifactDownloader.download(from: source, to: container)

			await taskStatus.update(state: .running(message: "Unpacking", progress: .indeterminate))
			try await artifactUnpacker.unpack(downloadedItemInContainer: container)

			guard let application = container.applications.first else {
				throw CachingApplicationDownloaderError.applicationNotFoundInArtifactContainer
			}

			return application
		}

		downloads[source] = Download(container: container, task: task)
		return try await task.value
	}

	/// Deletes all cached data that was tracked by this instance.
	///
	/// - Warning: Calling this function will cancel any in-progress downloads.
	func cleanUp() async throws {
		if let clearCacheTask {
			try await clearCacheTask.value
			return
		}

		let task = Task {
			downloads.values.forEach { $0.task.cancel() }

			for download in downloads.values {
				try await download.container.delete()
			}

			downloads.removeAll()
		}

		clearCacheTask = task
		try await task.value
		clearCacheTask = nil
	}
}

extension CachingApplicationDownloader {
	struct Download {
		let container: ArtifactContainer
		let task: Task<Application, Error>
	}
}

enum CachingApplicationDownloaderError: Error {
	case applicationNotFoundInArtifactContainer
}
