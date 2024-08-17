//
//  ShellCommand+iOSDeploy.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-11-11.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == iOSDeployCommand {
	static func iOSDeploy(_ command: Self) -> Self {
		command
	}
}

enum iOSDeployCommand {
	case list
	case install(device: String, bundleUrl: URL, noWifi: Bool)
	case launch(device: String, bundleId: String, noWifi: Bool)
}

extension iOSDeployCommand: ShellCommand {
	var executable: Executable {
		guard let executablePath = Bundle.main.path(forAuxiliaryExecutable: "ios-deploy") else {
			// ios-deploy is added by Xcode in the main project. It is not explicitly marked as a dependency
			// in Package.swift.
			fatalError("Attempting to execute ios-deploy but it was not found in the application bundle")
		}

		return .url(URL(filePath: executablePath))
	}

	var arguments: [String] {
		switch self {
			case .list:
				return ["--detect", "--timeout", "2", "--json"]

			case .install(let device, let bundleUrl, let noWifi):
				let bundlePath = bundleUrl.path(percentEncoded: false).wrappedInQuotationMarks()
				var items = ["--id", device, "--json", "--nostart", "--bundle", bundlePath]

				if noWifi {
					items.append("--no-wifi")
				}

				return items

			case .launch(let device, let bundleId, let noWifi):
				var items = ["--id", device, "--json", "--launch", "--bundle_id", bundleId]

				if noWifi {
					items.append("--no-wifi")
				}

				return items
		}
	}
}
