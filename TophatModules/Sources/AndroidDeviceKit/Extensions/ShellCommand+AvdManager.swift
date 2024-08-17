//
//  ShellCommand+AvdManager.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == AvdManagerCommand {
	static func avdManager(_ command: Self) -> Self {
		command
	}
}

enum AvdManagerCommand {
	case listAvd
}

extension AvdManagerCommand: ShellCommand {
	var executable: Executable {
		let executableName = "avdmanager"
		if let url = PathResolver.cmdLineTool(named: executableName) {
			return .url(url)
		}
		return .name(executableName)
	}

	var environment: [String: String] {
		guard let javaHome = PathResolver.javaHome?.path(percentEncoded: false) else {
			return [:]
		}

		return ["JAVA_HOME": javaHome]
	}

	var arguments: [String] {
		switch self {
			case .listAvd:
				return ["list", "avd"]
		}
	}
}
