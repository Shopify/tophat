//
//  ExtensionConfiguration.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-08.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import ExtensionFoundation

struct ExtensionConfiguration: AppExtensionConfiguration {
	private let service: ExtensionService

	init(appExtension: some TophatExtension) {
		self.service = ExtensionService(appExtension: appExtension)
	}

	func accept(connection: NSXPCConnection) -> Bool {
		let session = ExtensionXPCSession(connection: connection)
		session.activate()

		Task {
			for await message in session.receivedMessages {
				if let retrieveArtifactMessage = try? message.decode(as: RetrieveArtifactMessage.self) {
					do {
						let result = try await service.handleRetreiveArtifact(message: retrieveArtifactMessage.value)
						retrieveArtifactMessage.reply(.success(result))
					} catch {
						retrieveArtifactMessage.reply(.failure(error))
					}
				}

				if let fetchExtensionDescriptorMessage = try? message.decode(as: FetchExtensionSpecificationMessage.self) {
					let reply = service.handleExtensionDescriptor(message: fetchExtensionDescriptorMessage.value)
					fetchExtensionDescriptorMessage.reply(.success(reply))
				}

				if let cleanUpArtifactMessage = try? message.decode(as: CleanUpArtifactMessage.self) {
					try? await service.handleCleanUp(message: cleanUpArtifactMessage.value)
				}
			}
		}

		return true
	}
}
