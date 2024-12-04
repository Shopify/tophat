//
//  TophatExtensionXPCProtocol.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

@objc private protocol TophatExtensionXPCProtocol: NSObjectProtocol {
	func send(identifier: String, data: Data)
	func send(identifier: String, data: Data, reply: @escaping @Sendable (Data?, Error?) -> Void)
}

@_spi(TophatKitInternal)
@preconcurrency public final class ExtensionXPCSession: NSObject {
	private let connection: NSXPCConnection

	let receivedMessages: AsyncStream<ExtensionXPCReceivedMessageContainer>
	private let receivedMessagesContinuation: AsyncStream<ExtensionXPCReceivedMessageContainer>.Continuation

	public init(connection: NSXPCConnection) {
		self.connection = connection
		(self.receivedMessages, self.receivedMessagesContinuation) = AsyncStream.makeStream()

		super.init()

		let interface = NSXPCInterface(with: TophatExtensionXPCProtocol.self)

		connection.exportedInterface = interface
		connection.exportedObject = self
		connection.remoteObjectInterface = interface
	}

	public func activate() {
		connection.activate()
	}

	public func invalidate() {
		connection.invalidate()
	}
}

extension ExtensionXPCSession: TophatExtensionXPCProtocol {
	fileprivate func send(identifier: String, data: Data) {
		send(identifier: identifier, data: data, reply: { _, _ in })
	}

	fileprivate func send(identifier: String, data: Data, reply: @escaping @Sendable (Data?, Error?) -> Void) {
		let message = ExtensionXPCReceivedMessageContainer(
			identifier: identifier,
			data: data,
			replyHandler: reply
		)

		receivedMessagesContinuation.yield(message)
	}
}

extension ExtensionXPCSession {
	public func send<Message: ExtensionXPCMessage>(_ message: Message) async throws where Message.Reply == Never {
		guard let service = connection.remoteObjectProxy as? TophatExtensionXPCProtocol else {
			return
		}

		let data = try JSONEncoder().encode(message)
		service.send(identifier: message.identifier, data: data)
	}

	public func send<Message: ExtensionXPCMessage>(_ message: Message) async throws -> Message.Reply {
		let dataToSend = try JSONEncoder().encode(message)

		return try await withCheckedThrowingContinuation { continuation in
			let proxy = connection.remoteObjectProxyWithErrorHandler { error in
				continuation.resume(throwing: error)
			}

			guard let service = proxy as? TophatExtensionXPCProtocol else {
				continuation.resume(throwing: TophatExtensionXPCSessionError.invalidProtocol)
				return
			}

			service.send(identifier: message.identifier, data: dataToSend) { dataFromReply, error in
				if let nsError = error as? NSError, let localizedError = ExtensionXPCGenericLocalizedError(nsError: nsError) {
					continuation.resume(throwing: localizedError)
					return
				} else if let error {
					continuation.resume(throwing: error)
					return
				}

				if let dataFromReply {
					do {
						let reply = try JSONDecoder().decode(Message.Reply.self, from: dataFromReply)
						continuation.resume(returning: reply)
					} catch {
						continuation.resume(throwing: TophatExtensionXPCSessionError.invalidData)
					}

					return
				}

				continuation.resume(throwing: TophatExtensionXPCSessionError.missingData)
			}
		}
	}
}

@_spi(TophatKitInternal)
public enum TophatExtensionXPCSessionError: Error {
	case invalidProtocol
	case invalidData
	case missingData
}
