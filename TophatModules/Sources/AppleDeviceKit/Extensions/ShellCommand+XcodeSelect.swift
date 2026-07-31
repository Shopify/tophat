//
//  ShellCommand+XcodeSelect.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2026-07-31.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == XcodeSelectCommand {
	static func xcodeSelect(_ command: Self) -> Self {
		command
	}
}

enum XcodeSelectCommand {
	case printPath
}

extension XcodeSelectCommand: ShellCommand {
	var executable: Executable {
		.url(URL(filePath: "/usr/bin/xcode-select"))
	}

	var arguments: [ShellArgument] {
		switch self {
			case .printPath:
				["--print-path"]
		}
	}
}
