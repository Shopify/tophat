//
//  ShellCommand+ApkAnalyzer.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == ApkAnalyzerCommand {
	static func apkAnalyzer(_ command: Self) -> Self {
		command
	}
}

enum ApkAnalyzerCommand {
	case manifest(apkUrl: URL)
	case icon(apkUrl: URL)
}

extension ApkAnalyzerCommand: ShellCommand {
	var executable: Executable {
		let executableName = "apkanalyzer"
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
			case .manifest(let apkUrl):
				return ["manifest", "application-id", apkUrl.path(percentEncoded: false).wrappedInQuotationMarks()]
			case .icon(let apkUrl):
				return ["resources", "value", "--config", "xxhdpi", "--name", "ic_launcher", "--type", "mipmap", apkUrl.path(percentEncoded: false).wrappedInQuotationMarks()]
		}
	}
}
