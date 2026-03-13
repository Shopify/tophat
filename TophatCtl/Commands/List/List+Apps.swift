//
//  List+Apps.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import ArgumentParser
import TophatControlServices
import Foundation

extension List {
	struct Apps: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Lists all apps configured for Quick Launch in Tophat."
		)

		@Flag(name: .long, help: "Output the result as JSON.")
		var json = false

		func run() async throws {
			checkIfHostAppIsRunning()

			let reply = try await TophatRemoteControlService().send(request: ListAppsRequset())

			if json {
				let encoder = JSONEncoder()
				encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
				let data = try encoder.encode(reply.apps)
				print(String(data: data, encoding: .utf8)!)
			} else {
				print("Apps:")

				for app in reply.apps {
					print()

					print("‣\u{001B}[1m", app.name, "\u{001B}[22m")
					print("  Identifier:", app.id)
					print("  Platforms:", app.platforms.map { String(describing: $0) }.joined(separator: ", "))
					print("  Recipes:", app.recipeCount)
				}
			}
		}
	}
}
