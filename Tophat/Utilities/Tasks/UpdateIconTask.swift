//
//  UpdateIconTask.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-12.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import SwiftData

struct UpdateIconTask {
	let taskStatusReporter: TaskStatusReporter
	let context: OperationContext?

	@MainActor
	func callAsFunction(application: Application) async throws {
		guard let quickLaunchEntryID = context?.quickLaunchEntryID else {
			return
		}

		let status = TaskStatus(displayName: "Updating \(context?.appName ?? "App") Icon", initialState: .preparing)
		taskStatusReporter.add(status: status)

		defer {
			Task {
				status.markAsDone()
			}
		}

		if let iconURL = application.icon, let persistedIcon = try? store(icon: iconURL, for: quickLaunchEntryID) {
			let container = try ModelContainer(for: QuickLaunchEntry.self)
			let modelContext = ModelContext(container)

			let existingQuickLaunchEntryFetchDescriptor = FetchDescriptor<QuickLaunchEntry>(
				predicate: #Predicate { $0.id == quickLaunchEntryID }
			)

			if let existingQuickLaunchEntry = try modelContext.fetch(existingQuickLaunchEntryFetchDescriptor).first {
				existingQuickLaunchEntry.iconURL = persistedIcon.url
			}

			try modelContext.save()
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
