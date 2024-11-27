//
//  OperationContext.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

struct OperationContext {
	let appName: String?
	let quickLaunchEntryID: QuickLaunchEntry.ID?

	init(appName: String? = nil, quickLaunchEntryID: QuickLaunchEntry.ID? = nil) {
		self.appName = appName
		self.quickLaunchEntryID = quickLaunchEntryID
	}
}
