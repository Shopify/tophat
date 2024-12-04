//
//  TophatRemoteControlRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

/// The protocol you use to define notifications to be sent between Tophat processes.
public protocol TophatRemoteControlRequest: Codable {
	associatedtype Reply: Codable

	var id: UUID { get }
}

extension TophatRemoteControlRequest {
	static var notificationName: String {
		"Tophat.\(String(describing: self))"
	}

	static var replyNotificationName: String {
		"\(notificationName).Reply"
	}
}
