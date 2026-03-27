//
//  ShellCommand+Emulator.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == EmulatorCommand {
	static func emulator(_ command: Self) -> Self {
		command
	}
}

enum EmulatorCommand {
	case startDevice(name: String, reportConsolePort: Int)
}

extension EmulatorCommand: ShellCommand {
	var executable: Executable {
		.url(PathResolver.sdkRoot.appending(paths: ["emulator", "emulator"]))
	}

	var arguments: [ShellArgument] {
		switch self {
			case .startDevice(let name, let reportConsolePort):
				return [
					"-avd",
					.safe(name),
					"-report-console",
					.safe("tcp:\(reportConsolePort)"),
					.unsafe(">/dev/null"),
					.unsafe("2>&1"),
					.unsafe("&"),
					"nc",
					"-l",
					.safe(String(reportConsolePort)),
					.unsafe("</dev/null")
				]
		}
	}
}
