//
//  TophatInterProcessNotifier.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import Combine

public final class TophatInterProcessNotifier {
	private let notificationCenter = DistributedNotificationCenter.default()

	public init() {}

	public func send(notification: some TophatInterProcessNotification) {
		let notificationName = type(of: notification).name
		let userInfo = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(notification.payload)) as? [String: Any]

		notificationCenter.postNotificationName(
			.init(notificationName),
			object: nil,
			userInfo: userInfo?.compactMapValues { $0 },
			deliverImmediately: true
		)
	}

	public func publisher<T: Codable>(for notificationType: any TophatInterProcessNotification<T>.Type) -> AnyPublisher<T, Never> {
		notificationCenter
			.publisher(for: .init(notificationType.name), object: nil)
			.compactMap { notification in
				guard
					let data = try? JSONSerialization.data(withJSONObject: notification.userInfo as Any),
					let payload = try? JSONDecoder().decode(T.self, from: data)
				else {
					return nil
				}

				return payload
			}
			.eraseToAnyPublisher()
	}
}
