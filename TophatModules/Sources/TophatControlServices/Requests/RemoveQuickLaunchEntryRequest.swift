//
//  RemoveQuickLaunchEntryRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct RemoveQuickLaunchEntryRequest: TophatRemoteControlRequest {
	public typealias Reply = Never

	public let id: UUID
	public let quickLaunchEntryID: String

	public init(quickLaunchEntryID: String) {
		self.id = UUID()
		self.quickLaunchEntryID = quickLaunchEntryID
	}
}
