//
//  List.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import ArgumentParser

struct List: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Lists things Tophat knows about.",
		subcommands: [
			Providers.self
		]
	)
}
