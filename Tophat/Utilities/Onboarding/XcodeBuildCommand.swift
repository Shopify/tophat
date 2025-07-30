//
//  XcodeBuildCommand.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2025-07-24.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == XcodeBuildCommand {
	static func xcodebuild(_ command: Self) -> Self {
		command
	}
}

enum XcodeBuildCommand {
	case showSDKs
	case version
}

extension XcodeBuildCommand: ShellCommand {
	var executable: Executable {
		.url(URL(filePath: "/usr/bin/xcodebuild"))
	}

	var arguments: [String] {
		switch self {
		case .showSDKs:
			["-showsdks", "-json"]
		case .version:
			["-version"]
		}
	}
}
