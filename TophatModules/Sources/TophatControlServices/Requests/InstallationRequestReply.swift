//
//  InstallationRequestReply.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

public struct InstallationRequestReply: Codable, Sendable {
	public let errorMessage: String?

	public init(errorMessage: String? = nil) {
		self.errorMessage = errorMessage
	}
}
