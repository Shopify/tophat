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
	case application(url: URL, arguments: [String] = [])
	case applicationName(_ name: String)
}

extension OpenCommand: ShellCommand {
	var executable: Executable {
		.url(URL(filePath: "/usr/bin/open"))
	}

	var arguments: [ShellArgument] {
		switch self {
			case .application(let url, let arguments):
				var shellArguments: [ShellArgument] = ["-a", .safe(url.path(percentEncoded: false))]

				if !arguments.isEmpty {
					shellArguments.append(contentsOf: arguments.map { .safe($0) })
				}

				return shellArguments
			case .applicationName(let name):
				return ["-a", .safe(name)]
		}
	}
}
