//
//  ShellCommand+Aapt.swift
//  Tophat
//
//  Created by Harley Cooper on 1/12/23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == AaptCommand {
	static func aapt(_ command: Self) -> Self {
		command
	}
}

enum AaptCommand {
	case dumpBadging(apkUrl: URL)
}

extension AaptCommand: ShellCommand {
	var executable: Executable {
		let executableName = "aapt"
		if let url = PathResolver.buildTool(named: executableName) {
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
			case .dumpBadging(let apkUrl):
				return ["dump", "badging", apkUrl.path(percentEncoded: false).wrappedInQuotationMarks()]
		}
	}
}
