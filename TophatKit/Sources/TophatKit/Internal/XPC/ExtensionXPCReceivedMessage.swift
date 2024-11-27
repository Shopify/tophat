//
//  ExtensionXPCReceivedMessage.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-08.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

struct ExtensionXPCReceivedMessageContainer {
	private let identifier: String
	private let data: Data
	private let replyHandler: (Data?, Error?) -> Void

	init(identifier: String, data: Data, replyHandler: @escaping (Data?, Error?) -> Void) {
		self.identifier = identifier
		self.data = data
		self.replyHandler = replyHandler
	}

	public func decode<T: Codable>(as type: T.Type) throws -> ExtensionXPCReceivedMessage<T> {
		let value = try JSONDecoder().decode(T.self, from: data)

		guard value.identifier == identifier else {
			throw DecodeError.invalidIdentifier
		}

		return ExtensionXPCReceivedMessage(value: value, container: self)
	}

	fileprivate func reply(_ result: Result<some Codable, Error>) {
		switch result {
			case .success(let success):
				do {
					let data = try JSONEncoder().encode(success)
					replyHandler(data, nil)
				} catch {
					replyHandler(nil, error)
				}
			case .failure(let error):
				// The error will be an NSError over XPC anyway.
				replyHandler(nil, NSError(embeddingLocalizedDescriptionsFrom: error))
		}
	}
}

extension ExtensionXPCReceivedMessageContainer {
	enum DecodeError: Error {
		/// The type to decode to does not match the identifier of the received message.
		case invalidIdentifier
	}
}

struct ExtensionXPCReceivedMessage<Message: ExtensionXPCMessage> {
	private let container: ExtensionXPCReceivedMessageContainer

	public let value: Message

	init(value: Message, container: ExtensionXPCReceivedMessageContainer) {
		self.value = value
		self.container = container
	}

	public func reply(_ result: Result<Message.Reply, Error>) {
		container.reply(result)
	}
}
