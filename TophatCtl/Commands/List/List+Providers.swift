//
//  List+Providers.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import ArgumentParser
import TophatControlServices
import Foundation

extension List {
	struct Providers: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Lists all providers available in Tophat."
		)

		@Flag(name: .long, help: "Output the result as JSON.")
		var json = false

		func run() async throws {
			checkIfHostAppIsRunning()

			let reply = try await TophatRemoteControlService().send(request: ListProvidersRequest())

			if json {
				let encoder = JSONEncoder()
				encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
				let data = try encoder.encode(reply.providers)
				print(String(data: data, encoding: .utf8)!)
			} else {
				print("Providers:")

				for provider in reply.providers {
					print()

					print("‣\u{001B}[1m", provider.title, "\u{001B}[22m")
					print("  Identifier:", provider.id)
					print("  Extension:", provider.extensionTitle)
					print("  Parameters:")

					for parameter in provider.parameters {
						print("    ‣ Key:", parameter.key)
						print("      Title:", parameter.title)
					}
				}
			}
		}
	}
}
