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
	case openURL(device: String, url: String)
	case terminate(device: String, bundleIdentifier: String)
}

extension SimCtlCommand: ShellCommand {
	var executable: Executable {
		.url(URL(filePath: "/usr/bin/xcrun"))
	}

	var arguments: [String] {
		switch self {
			case .list(let type, let available):
				return ["simctl", "list", "--json", type.rawValue, available ? "available" : ""]

			case .boot(let device):
				return ["simctl", "boot", device]

			case .install(let device, let bundleUrl):
				return ["simctl", "install", device, bundleUrl.path(percentEncoded: false).wrappedInQuotationMarks()]

			case .launch(let device, let bundleIdentifier, let arguments):
				return ["simctl", "launch", device, bundleIdentifier] + arguments

			case .openURL(let device, let url):
				return ["simctl", "openurl", device, url]

			case .terminate(let device, let bundleIdentifier):
				return ["simctl", "terminate", device, bundleIdentifier]
		}
	}
}
