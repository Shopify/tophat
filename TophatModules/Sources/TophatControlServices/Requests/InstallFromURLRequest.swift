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
	public let deviceIdentifier: String?

	public init(url: URL, launchArguments: [String], deviceIdentifier: String? = nil) {
		self.id = UUID()
		self.url = url
		self.launchArguments = launchArguments
		self.deviceIdentifier = deviceIdentifier
	}
}
