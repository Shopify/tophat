//
//  AndroidApplication.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-21.
//  Copyright © 2022 Shopify. All rights reserved.
//

import AndroidDeviceKit
import Foundation
import TophatFoundation
import ZIPFoundation

struct AndroidApplication: Application {
	let url: URL

	var name: String? {
		try? Aapt.readAppName(apkUrl: url)
	}

	var icon: URL? {
		guard let path = try? ApkAnalyzer.getIconPath(apkUrl: url),
			  let archive = try? Archive(url: url, accessMode: .read, pathEncoding: nil),
			  let entry = archive[path]
		else {
			return nil
		}

		let iconURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
		_ = try? archive.extract(entry, to: iconURL)

		return iconURL
	}

	var targets: Set<DeviceType> {
		// Android applications run anywhere.
		[.simulator, .device]
	}

	var platform: Platform {
		.android
	}

	var bundleIdentifier: String {
		get throws {
			guard let packageName = try? Aapt.readPackageName(apkUrl: url) else {
				throw ApplicationError.failedToReadBundleIdentifier
			}

			return packageName
		}
	}

	func validateEligibility(for device: Device) throws {
		guard platform == device.runtime.platform, targets.contains(device.type) else {
			throw ApplicationError.incompatible(application: self, device: device)
		}
	}
}

extension AndroidApplication: Deletable {
	nonisolated func delete() async throws {
		try FileManager.default.removeItem(at: url)
	}
}
