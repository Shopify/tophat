//
//  ShellCommand+SimCtl.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == SimCtlCommand {
	static func simCtl(_ command: Self) -> Self {
		command
	}
}

enum SimCtlCommand {
	enum ListItemType: String {
		case devices
		case deviceTypes = "devicetypes"
		case runtimes
		case pairs
	}

	case list(type: ListItemType, available: Bool)
	case boot(device: String)
	case install(device: String, bundleUrl: URL)
	case launch(device: String, bundleIdentifier: String, arguments: [String])
	case terminate(device: String, bundleIdentifier: String)
}

extension SimCtlCommand: ShellCommand {
	var executable: Executable {
		.url(URL(filePath: "/usr/bin/xcrun"))
	}

	var arguments: [ShellArgument] {
		switch self {
			case .list(let type, let available):
				return ["simctl", "list", "--json", .safe(type.rawValue), .safe(available ? "available" : "")]

			case .boot(let device):
				return ["simctl", "boot", .safe(device)]

			case .install(let device, let bundleUrl):
				return ["simctl", "install", .safe(device), .safe(bundleUrl.path(percentEncoded: false))]

			case .launch(let device, let bundleIdentifier, let arguments):
				return ["simctl", "launch", .safe(device), .safe(bundleIdentifier)] + arguments.map { .safe($0) }

			case .terminate(let device, let bundleIdentifier):
				return ["simctl", "terminate", .safe(device), .safe(bundleIdentifier)]
		}
	}
}
