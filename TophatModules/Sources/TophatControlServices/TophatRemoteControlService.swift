//
//  TophatRemoteControlService.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public final class TophatRemoteControlService: Sendable {
	private let notificationCenter = DistributedNotificationCenter.default()

	public init() {}

	public func send<T: TophatRemoteControlRequest>(request: T) throws where T.Reply == Never {
		try sendAndForget(request: request)
	}

	@discardableResult
	public func send<T: TophatRemoteControlRequest>(request: T, timeout: TimeInterval = 10) async throws -> T.Reply {
		try sendAndForget(request: request)

		let waitForReplyTask = Task {
			let notification = await notificationCenter
				.notifications(named: .init(type(of: request).replyNotificationName), object: nil)
				.first { ($0.object as? String) == request.id.uuidString }

			guard let notification else {
				throw TophatRemoteControlServiceError.replyNotReceived
			}

			do {
				let replyData = try JSONSerialization.data(withJSONObject: notification.userInfo as Any)
				let reply = try JSONDecoder().decode(T.Reply.self, from: replyData)

				try Task.checkCancellation()

				return reply

			} catch {
				throw TophatRemoteControlServiceError.invalidResponse
			}
		}

		let timeoutTask = Task {
			try await Task.sleep(for: .seconds(timeout))
			waitForReplyTask.cancel()
		}

		do {
			let result = try await waitForReplyTask.value
			timeoutTask.cancel()
			return result
		} catch {
			throw TophatRemoteControlServiceError.replyTimedOut
		}
	}

	func sendAndForget(request: some TophatRemoteControlRequest) throws {
		let userInfo = try JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any]

		notificationCenter.postNotificationName(
			.init(type(of: request).notificationName),
			object: nil,
			userInfo: userInfo?.compactMapValues { $0 },
			deliverImmediately: true
		)
	}

	public func requests<T: TophatRemoteControlRequest>(
		for notificationType: T.Type
	) -> AsyncStream<TophatRemoteControlReceivedRequest<T>> {
		let notifications = notificationCenter
			.notifications(named: .init(notificationType.notificationName), object: nil)

		return AsyncStream { continuation in
			let task = Task {
				for await notification in notifications {
					guard
						let data = try? JSONSerialization.data(withJSONObject: notification.userInfo as Any),
						let request = try? JSONDecoder().decode(T.self, from: data)
					else {
						continue
					}

					continuation.yield(.init(value: request))
				}
			}

			continuation.onTermination = { _ in
				task.cancel()
			}
		}
	}
}

enum TophatRemoteControlServiceError: Error {
	case replyNotReceived
	case replyTimedOut
	case invalidResponse
}

extension TophatRemoteControlServiceError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .replyTimedOut:
				"The operation timed out."
			default:
				"An unexpected error occurred."
		}
	}
}
