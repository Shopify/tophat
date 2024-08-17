//
//  ShellCommand+Open.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == OpenCommand {
	static func open(_ command: Self) -> Self {
		command
	}
}

enum OpenCommand {
	case simulator
}

extension OpenCommand: ShellCommand {
	var executable: Executable {
		.url(URL(filePath: "/usr/bin/open"))
	}

	var arguments: [String] {
		switch self {
			case .simulator:
				return ["-a", "Simulator.app"]
		}
	}
}
