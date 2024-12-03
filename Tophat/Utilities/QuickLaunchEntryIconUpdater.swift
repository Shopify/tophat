//
//  QuickLaunchEntryIconUpdater.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-12-03.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import SwiftData

protocol QuickLaunchEntryIconUpdating: Sendable {
	func updateIcon(iconURL: URL, quickLaunchEntryID: QuickLaunchEntry.ID) async throws
}

struct QuickLaunchEntryIconUpdater: Sendable, QuickLaunchEntryIconUpdating {
	private let modelContainer: ModelContainer

	init(modelContainer: ModelContainer) {
		self.modelContainer = modelContainer
	}

	func updateIcon(iconURL: URL, quickLaunchEntryID: QuickLaunchEntry.ID) async throws {
		let modelContext = ModelContext(modelContainer)

		var fetchDescriptor = FetchDescriptor<QuickLaunchEntry>(
			predicate: #Predicate { $0.id == quickLaunchEntryID }
		)
		fetchDescriptor.fetchLimit = 1

		guard let quickLaunchEntry = try modelContext.fetch(fetchDescriptor).first else {
			return
		}

		let persistedIcon = try ApplicationIcon.createAndPersist(fromOrigin: iconURL, for: quickLaunchEntryID)

		quickLaunchEntry.iconURL = persistedIcon.url
		try modelContext.save()
	}
}
