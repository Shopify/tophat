//
//  Apps.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import ArgumentParser

struct Apps: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		abstract: "Adds, removes, or modifies Quick Launch entries.",
		subcommands: [
			Add.self,
			Remove.self
		]
	)
}
