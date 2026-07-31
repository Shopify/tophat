//
//  XcodeHelper.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2026-07-31.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import ShellKit

struct XcodeHelper {
	static func deviceHubURL() -> URL? {
		guard let selectedDeveloperDirectoryPath = try? run(command: .xcodeSelect(.printPath), log: log) else {
			return nil
		}

		let trimmedDeveloperDirectoryPath = selectedDeveloperDirectoryPath.trimmingCharacters(in: .whitespacesAndNewlines)

		guard !trimmedDeveloperDirectoryPath.isEmpty else {
			return nil
		}

		let deviceHubURL = URL(filePath: trimmedDeveloperDirectoryPath, directoryHint: .isDirectory)
			.deletingLastPathComponent()
			.appending(path: "Applications", directoryHint: .isDirectory)
			.appending(path: "DeviceHub.app", directoryHint: .isDirectory)

		guard FileManager.default.fileExists(atPath: deviceHubURL.path(percentEncoded: false)) else {
			return nil
		}

		return deviceHubURL
	}
}
