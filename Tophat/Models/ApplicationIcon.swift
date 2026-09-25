//
//  ApplicationIcon.swift
//  Tophat
//
//  Created by Harley Cooper on 2023-01-09.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

public struct ApplicationIcon {
	public let url: URL

	public init(url: URL) {
		self.url = url
	}

	public static func createAndPersist(fromOrigin iconURL: URL, for appID: String) throws -> Self {
		try createAndPersist(fromOrigin: iconURL, for: appID, directoryURL: iconDirectoryURL())
	}

	static func createAndPersist(fromOrigin iconURL: URL, for appID: String, directoryURL: URL) throws -> Self {
		guard appID.isValidQuickLaunchEntryID else {
			throw ApplicationIconError.invalidIdentifier
		}

		let destinationURL = directoryURL.appending(component: appID, directoryHint: .notDirectory)
		try FileManager.default.replaceItem(at: destinationURL, withCopyOfItemAt: iconURL)

		return Self(url: destinationURL)
	}

	private static func iconDirectoryURL() throws -> URL {
		let appSupportDirectoryURL = try FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)

		let bundleIdentifier = Bundle.main.bundleIdentifier!
		let url = appSupportDirectoryURL.appending(path: bundleIdentifier)
		try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

		return url
	}
}

enum ApplicationIconError: Error {
	case invalidIdentifier
}

private extension FileManager {
	func replaceItem(at originalItemURL: URL, withCopyOfItemAt newItemURL: URL) throws {
		let itemReplacementURL = try url(
			for: .itemReplacementDirectory,
			in: .userDomainMask,
			appropriateFor: newItemURL.deletingPathExtension(),
			create: true
		)

		let temporaryFileURL = itemReplacementURL.appendingPathComponent(newItemURL.lastPathComponent)
		try self.copyItem(at: newItemURL, to: temporaryFileURL)

		try FileManager.default.replaceItem(
			at: originalItemURL,
			withItemAt: temporaryFileURL,
			backupItemName: nil,
			resultingItemURL: nil
		)

		try self.removeItem(at: itemReplacementURL)
	}
}
