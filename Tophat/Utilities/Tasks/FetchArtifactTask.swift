//
//  FetchArtifactTask.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

struct FetchArtifactTask {
	struct Result {
		let application: Application
	}

	let taskStatusReporter: TaskStatusReporter
	let pinnedApplicationState: PinnedApplicationState
	let context: LaunchContext?

	private let status: TaskStatus

	init(taskStatusReporter: TaskStatusReporter, pinnedApplicationState: PinnedApplicationState, context: LaunchContext?) {
		self.taskStatusReporter = taskStatusReporter
		self.pinnedApplicationState = pinnedApplicationState
		self.context = context

		self.status = TaskStatus(displayName: "Downloading \(context?.appName ?? "App")", initialState: .preparing)
	}

	func callAsFunction(at url: URL) async throws -> Result {
		await taskStatusReporter.add(status: status)

		defer {
			Task {
				await status.markAsDone()
			}
		}

		log.info("Downloading artifact from \(url.absoluteString)")
		await status.update(state: .running(message: "Downloading"))
		taskStatusReporter.notify(message: "Downloading \(context?.appName ?? "application")…")
		let downloadedArtifactUrl = try await downloadArtifact(at: url)
		log.info("Artifact downloaded to \(downloadedArtifactUrl.path(percentEncoded: false))")

		log.info("Unpacking artifact at \(downloadedArtifactUrl.path(percentEncoded: false))")
		await status.update(state: .running(message: "Unpacking"))
		let application = try ArtifactUnpacker().unpack(artifactURL: downloadedArtifactUrl)
		log.info("Artifact unpacked to \(application.url.path(percentEncoded: false))")

		Task.detached {
			let updateIcon = UpdateIconTask(
				taskStatusReporter: taskStatusReporter,
				pinnedApplicationState: pinnedApplicationState,
				context: context
			)

			try await updateIcon(application: application)
		}

		return Result(application: application)
	}

	private func downloadArtifact(at url: URL) async throws -> URL {
		let artifactDownloader = ArtifactDownloader()

		let task = Task {
			for await progress in artifactDownloader.progressUpdates {
				await status.update(state: .running(message: "Downloading", progress: progress))
			}
		}

		let downloadedArtifactURL = try await artifactDownloader.download(artifactUrl: url)
		task.cancel()

		return downloadedArtifactURL
	}
}
