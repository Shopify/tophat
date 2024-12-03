//
//  InstallFromURLRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct InstallFromURLRequest: TophatRemoteControlRequest {
	public typealias Reply = InstallationRequestReply

	public let id: UUID
	public let url: URL
	public let launchArguments: [String]

	public init(url: URL, launchArguments: [String]) {
		self.id = UUID()
		self.url = url
		self.launchArguments = launchArguments
	}
}
