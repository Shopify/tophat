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

	init(appName: String? = nil, pinnedApplicationId: PinnedApplication.ID? = nil) {
		self.appName = appName
		self.pinnedApplicationId = pinnedApplicationId
	}
}
