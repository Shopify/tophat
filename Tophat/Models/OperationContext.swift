//
//  OperationContext.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

struct OperationContext {
	let quickLaunchEntry: QuickLaunchEntry?

	init(quickLaunchEntry: QuickLaunchEntry? = nil) {
		self.quickLaunchEntry = quickLaunchEntry
	}
}
