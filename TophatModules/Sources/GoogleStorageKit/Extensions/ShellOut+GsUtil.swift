//
//  ShellOutCommand+GSUtil.swift
//  GoogleStorageKit
//
//  Created by Lukas Romsicki on 2022-10-31.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == GSUtilCommand {
	static func gsUtil(_ command: Self) -> Self {
		command
	}
}

enum GSUtilCommand {
	case copy(remoteUrl: URL, localUrl: URL)
}

extension GSUtilCommand: ShellCommand {
	var executable: Executable {
		.url(PathResolver.gsUtilPath)
	}

	var environment: [String: String] {
		PathResolver.gsUtilEnvironment ?? [:]
	}

	var arguments: [String] {
		switch self {
			case .copy(let remoteUrl, let localUrl):
				return ["cp", remoteUrl.absoluteString, localUrl.path(percentEncoded: false).wrappedInQuotationMarks()]
		}
	}
}
