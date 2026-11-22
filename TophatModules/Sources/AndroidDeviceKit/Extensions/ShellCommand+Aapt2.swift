//
//  ShellCommand+Aapt2.swift
//  AndroidDeviceKit
//
//  Created by Harley Cooper on 1/12/23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == Aapt2Command {
	static func aapt2(_ command: Self) -> Self {
		command
	}
}

enum Aapt2Command {
	case dumpBadging(apkUrl: URL)
	case dumpManifest(apkUrl: URL)
	case dumpResources(apkUrl: URL)
}

extension Aapt2Command: ShellCommand {
	var executable: Executable {
		let executableName = "aapt2"

		if let url = PathResolver.buildTool(named: executableName) {
			return .url(url)
		}

		return .name(executableName)
	}

	var arguments: [ShellArgument] {
		switch self {
			case .dumpBadging(let apkUrl):
				return ["dump", "badging", .safe(apkUrl.path(percentEncoded: false))]

			case .dumpManifest(let apkUrl):
				return ["dump", "xmltree", "--file", "AndroidManifest.xml", .safe(apkUrl.path(percentEncoded: false))]

			case .dumpResources(let apkUrl):
				return ["dump", "resources", .safe(apkUrl.path(percentEncoded: false))]
		}
	}
}
