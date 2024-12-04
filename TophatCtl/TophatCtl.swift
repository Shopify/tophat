//
//  TophatCtl.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-26.
//  Copyright © 2023 Shopify. All rights reserved.
//

import ArgumentParser

@main
struct TophatCtl: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "tophatctl",
		abstract: "A utility for interacting with Tophat from command line applications.",
		subcommands: [
			Install.self,
			Apps.self,
			List.self
		]
	)
}
