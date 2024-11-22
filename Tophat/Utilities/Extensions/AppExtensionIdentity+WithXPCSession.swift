//
//  AppExtensionIdentity+WithXPCSession.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import ExtensionFoundation
@_spi(TophatKitInternal) import TophatKit

extension AppExtensionIdentity {
	func withXPCSession<T>(perform: (ExtensionXPCSession) async throws -> T) async throws -> T {
		let configuration = AppExtensionProcess.Configuration(appExtensionIdentity: self)
		let process = try await AppExtensionProcess(configuration: configuration)

		let connection = try process.makeXPCConnection()
		let session = ExtensionXPCSession(connection: connection)

		session.activate()

		defer {
			session.invalidate()
		}

		return try await perform(session)
	}
}
