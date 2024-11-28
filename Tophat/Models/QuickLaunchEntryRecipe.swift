//
//  QuickLaunchEntryRecipe.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-25.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import SwiftData

@Model
final class QuickLaunchEntryRecipe: Hashable {
	var artifactProviderID: String
	var artifactProviderParameters: [String: String]
	var launchArguments: [String]
	var platformHint: Platform
	var destinationHint: DeviceType?

	init(
		artifactProviderID: String,
		artifactProviderParameters: [String: String],
		launchArguments: [String],
		platformHint: Platform,
		destinationHint: DeviceType? = nil
	) {
		self.artifactProviderID = artifactProviderID
		self.artifactProviderParameters = artifactProviderParameters
		self.launchArguments = launchArguments
		self.platformHint = platformHint
		self.destinationHint = destinationHint
	}
}
