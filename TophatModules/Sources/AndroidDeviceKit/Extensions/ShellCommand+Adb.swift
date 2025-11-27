//
//  ShellCommand+Adb.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import ShellKit

extension ShellCommand where Self == AdbCommand {
	static func adb(_ command: Self) -> Self {
		command
	}
}

enum AdbCommand {
	case devices
	case install(serial: String, apkUrl: URL)
	case launch(serial: String, componentName: String, arguments: [String])
  case deepLink(serial: String, deepLink: String)
	case avdName(serial: String)
	case getProp(serial: String, property: String)
	case waitForDevice(serial: String)
	case resolveActivity(serial: String, packageName: String)
}

extension AdbCommand: ShellCommand {
	var executable: Executable {
		.url(PathResolver.adb)
	}

	var arguments: [String] {
		switch self {
			case .devices:
				return ["devices", "-l"]

			case .install(let serial, let apkUrl):
				return ["-s", serial, "install", "-r", "-d", apkUrl.path(percentEncoded: false).wrappedInQuotationMarks()]

			case .launch(let serial, let componentName, let arguments):
				let extras: [String] = if !arguments.isEmpty {
					["--esa", "TOPHAT_ARGUMENTS", arguments.joined(separator: ",")]
				} else {
					[]
				}

				return ["-s", serial, "shell", "am", "start", "-n", componentName] + extras

      case .deepLink(let serial, let deepLink):
        return ["-s", serial, "shell", "am", "start", "-a", "android.intent.action.VIEW", "-d", deepLink.wrappedInQuotationMarks()]

			case .avdName(let serial):
				return ["-s", serial, "emu", "avd", "name"]

			case .getProp(let serial, let property):
				return ["-s", serial, "shell", "getprop", property]

			case .waitForDevice(let serial):
				return ["-s", serial, "wait-for-device", "shell", "'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'"]

			case .resolveActivity(let serial, let packageName):
				return ["-s", serial, "shell", "pm", "resolve-activity", "--brief", packageName]
		}
	}
}
