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
	case startDevice(name: String)
}

extension EmulatorCommand: ShellCommand {
	var executable: Executable {
		.url(PathResolver.sdkRoot.appending(paths: ["emulator", "emulator"]))
	}

	var arguments: [String] {
		switch self {
			case .startDevice(let name):
				return ["-avd", name, "&"]
		}
	}
}
