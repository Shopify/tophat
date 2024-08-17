//
//  UpdateIconTask.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-12.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

struct UpdateIconTask {
	let taskStatusReporter: TaskStatusReporter
	let pinnedApplicationState: PinnedApplicationState
	let context: LaunchContext?

	@MainActor
	func callAsFunction(application: Application) async throws {
		guard let pinnedApplicationId = context?.pinnedApplicationId else {
			return
		}

		let status = TaskStatus(displayName: "Updating \(context?.appName ?? "App") Icon", initialState: .preparing)
		taskStatusReporter.add(status: status)

		defer {
			Task {
				status.markAsDone()
			}
		}

		if let iconURL = application.icon, let persistedIcon = try? store(icon: iconURL, for: pinnedApplicationId) {
			pinnedApplicationState.update(icon: persistedIcon, for: pinnedApplicationId)
		}
	}

	private func store(icon iconURL: URL, for appId: String) throws -> ApplicationIcon? {
		do {
			return try ApplicationIcon.createAndPersist(fromOrigin: iconURL, for: appId)
		} catch {
			log.error("Failed to save icon for pinned application with identifier \(appId): \(error)")
			throw error
		}
	}
}

private extension PinnedApplicationState {
	func update(icon: ApplicationIcon, for pinnedApplicationId: PinnedApplication.ID) {
		guard let index = index(pinnedApplicationId: pinnedApplicationId) else {
			return
		}

		var modifiedElement = pinnedApplications[index]
		modifiedElement.icon = icon
		pinnedApplications[index] = modifiedElement
	}

	private func index(pinnedApplicationId: PinnedApplication.ID) -> Int? {
		pinnedApplications.firstIndex { $0.id == pinnedApplicationId }
	}
}
