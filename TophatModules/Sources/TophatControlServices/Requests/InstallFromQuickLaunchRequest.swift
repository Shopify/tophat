//
//  InstallFromQuickLaunchRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct InstallFromQuickLaunchRequest: TophatRemoteControlRequest {
	public typealias Reply = InstallationRequestReply

	public let id: UUID
	public let quickLaunchEntryID: String

	public init(quickLaunchEntryID: String) {
		self.id = UUID()
		self.quickLaunchEntryID = quickLaunchEntryID
	}
}
