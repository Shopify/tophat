//
//  QuickLaunchEntry.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-22.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import SwiftData

@Model
final class QuickLaunchEntry: Identifiable, Hashable {
	typealias Source = InstallRecipe

	@Attribute(.unique)
	var id: String

	var name: String

	var iconURL: URL?

	@Relationship(deleteRule: .cascade, minimumModelCount: 1)
	var sources: [QuickLaunchEntrySource]

	var order: Int = 0

	init(id: String? = nil, name: String, iconURL: URL? = nil, sources: [QuickLaunchEntrySource], order: Int = 0) {
		self.id = id ?? UUID().uuidString
		self.name = name
		self.iconURL = iconURL
		self.sources = sources
		self.order = order
	}
}

extension QuickLaunchEntry {
	var platforms: Set<Platform> {
		Set(sources.compactMap { $0.platformHint })
	}
}
