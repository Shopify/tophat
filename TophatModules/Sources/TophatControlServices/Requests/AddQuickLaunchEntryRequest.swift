//
//  AddQuickLaunchEntryRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct AddQuickLaunchEntryRequest: TophatRemoteControlRequest {
	public typealias Reply = Never

	public let id: UUID
	public let configuration: UserSpecifiedQuickLaunchEntryConfiguration

	public init(configuration: UserSpecifiedQuickLaunchEntryConfiguration) {
		self.id = UUID()
		self.configuration = configuration
	}
}
