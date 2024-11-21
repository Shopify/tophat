//
//  FetchArtifactTask.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

extension FetchArtifactTask: ArtifactDownloading {
	func download(source: RemoteArtifactSource) async throws -> any Application {
		try await callAsFunction(from: .remote(source: source)).application
	}
}

struct FetchArtifactTask {
	struct Result {
		let application: Application
	}

	let taskStatusReporter: TaskStatusReporter
	let pinnedApplicationState: PinnedApplicationState
	let buildDownloader: ArtifactDownloader
	let context: LaunchContext?

	init(
		taskStatusReporter: TaskStatusReporter,
		pinnedApplicationState: PinnedApplicationState,
		artifactDownloader: ArtifactDownloader,
		context: LaunchContext?
	) {
		self.taskStatusReporter = taskStatusReporter
		self.pinnedApplicationState = pinnedApplicationState
		self.buildDownloader = artifactDownloader
		self.context = context
	}

	func callAsFunction(from location: ArtifactLocation) async throws -> Result {
		let status = TaskStatus(displayName: "Downloading \(context?.appName ?? "App")", initialState: .running(message: "Downloading", progress: .indeterminate))
		await taskStatusReporter.add(status: status)

		defer {
			Task {
				await status.markAsDone()
			}
		}

		let application = switch location {
			case .remote(let source):
				try await buildDownloader.download(from: source).application
			case .local(let application):
				application
		}

		Task {
			let updateIcon = UpdateIconTask(
				taskStatusReporter: taskStatusReporter,
				pinnedApplicationState: pinnedApplicationState,
				context: context
			)

			try await updateIcon(application: application)
		}

		return Result(application: application)
	}
}
