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
	case avdName(serial: String)
	case getProp(serial: String, property: String)
	case waitForDevice(serial: String)
	case resolveActivity(serial: String, packageName: String)
	case push(serial: String, localPath: URL, remotePath: String)
	case pull(serial: String, remotePath: String, localPath: URL)
	case packagePath(serial: String, packageName: String)
	case shell(serial: String, command: String)
}

extension AdbCommand: ShellCommand {
	var executable: Executable {
		.url(PathResolver.adb)
	}

	var arguments: [ShellArgument] {
		switch self {
			case .devices:
				return ["devices", "-l"]

			case .install(let serial, let apkUrl):
				return ["-s", .safe(serial), "install", "-r", "-d", .safe(apkUrl.path(percentEncoded: false))]

			case .launch(let serial, let componentName, let arguments):
				let extras: [ShellArgument] = if !arguments.isEmpty {
					["--esa", "TOPHAT_ARGUMENTS", .safe(arguments.joined(separator: ","))]
				} else {
					[]
				}

				return ["-s", .safe(serial), "shell", "am", "start", "-n", .safe(componentName)] + extras

			case .avdName(let serial):
				return ["-s", .safe(serial), "emu", "avd", "name"]

			case .getProp(let serial, let property):
				return ["-s", .safe(serial), "shell", "getprop", .safe(property)]

			case .waitForDevice(let serial):
				return ["-s", .safe(serial), "wait-for-device"]

			case .resolveActivity(let serial, let packageName):
				return ["-s", .safe(serial), "shell", "pm", "resolve-activity", "--brief", .safe(packageName)]

			case .push(let serial, let localPath, let remotePath):
				return ["-s", .safe(serial), "push", .safe(localPath.path(percentEncoded: false)), .safe(remotePath)]

			case .pull(let serial, let remotePath, let localPath):
				return ["-s", .safe(serial), "pull", .safe(remotePath), .safe(localPath.path(percentEncoded: false))]

			case .packagePath(let serial, let packageName):
				return ["-s", .safe(serial), "shell", "pm", "path", .safe(packageName)]

			case .shell(let serial, let command):
				return ["-s", .safe(serial), "shell", .unsafe(command)]
		}
	}
}
