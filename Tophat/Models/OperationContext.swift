//
//  OperationContext.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

struct OperationContext: Sendable {
	let quickLaunchEntryID: QuickLaunchEntry.ID?
	let applicationDisplayName: String?
	let targetDeviceIdentifier: String?

	init(quickLaunchEntryID: QuickLaunchEntry.ID? = nil, applicationDisplayName: String? = nil, targetDeviceIdentifier: String? = nil) {
		self.quickLaunchEntryID = quickLaunchEntryID
		self.applicationDisplayName = applicationDisplayName
		self.targetDeviceIdentifier = targetDeviceIdentifier
	}
}
