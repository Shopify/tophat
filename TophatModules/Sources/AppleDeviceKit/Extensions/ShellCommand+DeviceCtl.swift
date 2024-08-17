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

	var arguments: [String] {
		switch self {
			case .list(let outputUrl):
				return [
					"devicectl",
					"list",
					"devices",
					"--filter", "hardwareProperties.platform MATCHES 'iOS'".wrappedInQuotationMarks(),
					"--json-output", outputUrl.formattedAsArgument()
				]

			case .install(let device, let bundleUrl):
				return ["devicectl", "device", "install", "app", "--device", device, bundleUrl.formattedAsArgument()]

			case .launch(let device, let bundleId, let outputUrl, let arguments):
				return ["devicectl", "device", "process", "launch", "--device", device, bundleId, "--json-output", outputUrl.formattedAsArgument()] + arguments

			case .lockState(let device, let outputURL):
				return ["devicectl", "device", "info", "lockState", "--device", device, "--json-output", outputURL.formattedAsArgument()]
		}
	}
}

private extension URL {
	func formattedAsArgument() -> String {
		path(percentEncoded: false).wrappedInQuotationMarks()
	}
}
