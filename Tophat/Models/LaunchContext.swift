//
//  LaunchContext.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

struct LaunchContext {
	let appName: String?
	let pinnedApplicationId: PinnedApplication.ID?
	let arguments: [String]?

	init(appName: String? = nil, pinnedApplicationId: PinnedApplication.ID? = nil, arguments: [String]? = nil) {
		self.appName = appName
		self.pinnedApplicationId = pinnedApplicationId
		self.arguments = arguments
	}
}
