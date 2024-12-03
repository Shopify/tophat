//
//  TophatRemoteControlReceivedRequest.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public struct TophatRemoteControlReceivedRequest<T: TophatRemoteControlRequest> {
	public let value: T

	public func reply(_ reply: T.Reply) {
		guard let userInfo = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(reply)) as? [AnyHashable: Any] else {
			log.warning("[TophatRemoteControlReceivedRequest] Warning: The reply data cannot be represented as JSON! It will not be sent.")
			return
		}

		DistributedNotificationCenter.default().postNotificationName(
			.init(type(of: value).replyNotificationName),
			object: value.id.uuidString,
			userInfo: userInfo,
			deliverImmediately: true
		)
	}
}
