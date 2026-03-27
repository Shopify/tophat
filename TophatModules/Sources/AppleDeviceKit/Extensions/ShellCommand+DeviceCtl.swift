//
//  ShellCommand+DeviceCtl.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2023-07-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == DeviceCtlCommand {
	static func deviceCtl(_ command: Self) -> Self {
		command
	}
}

enum DeviceCtlCommand {
	case list(outputUrl: URL)
	case install(device: String, bundleUrl: URL)
	case launch(device: String, bundleId: String, outputUrl: URL, arguments: [String])
	case lockState(device: String, outputURL: URL)
}

extension DeviceCtlCommand: ShellCommand {
	var executable: Executable {
		.url(URL(filePath: "/usr/bin/xcrun"))
	}

	var arguments: [ShellArgument] {
		switch self {
			case .list(let outputUrl):
				return [
					"devicectl",
					"list",
					"devices",
					"--filter", "hardwareProperties.platform MATCHES 'iOS'",
					"--json-output", .safe(outputUrl.formattedAsArgument())
				]

			case .install(let device, let bundleUrl):
				return ["devicectl", "device", "install", "app", "--device", .safe(device), .safe(bundleUrl.formattedAsArgument())]

			case .launch(let device, let bundleId, let outputUrl, let arguments):
				return ["devicectl", "device", "process", "launch", "--device", .safe(device), .safe(bundleId), "--json-output", .safe(outputUrl.formattedAsArgument())] + arguments.map { .safe($0) }

			case .lockState(let device, let outputURL):
				return ["devicectl", "device", "info", "lockState", "--device", .safe(device), "--json-output", .safe(outputURL.formattedAsArgument())]
		}
	}
}

private extension URL {
	func formattedAsArgument() -> String {
		path(percentEncoded: false)
	}
}
