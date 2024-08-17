//
//  PathResolver.swift
//  GoogleStorageKit
//
//  Created by Lukas Romsicki on 2022-10-31.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

// Shorthand for use within the library.
typealias PathResolver = GoogleStoragePathResolver

public struct GoogleStoragePathResolver {
	public static var delegate: GoogleStoragePathResolverDelegate?

	private static let caskPath = URL(filePath: "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/gsutil")
	private static let legacyCaskPath = URL(filePath: "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/gsutil")
	private static let usrLocalPath = URL(filePath: "/usr/local/bin/gsutil")
	private static let cloudSDKVariable = ["CLOUDSDK_PYTHON": "/usr/local/opt/python@3.8/libexec/bin/python"]

	public static var gsUtilPath: URL {
		if let customPath = delegate?.pathToGSUtil() {
			return customPath
		}

		if caskPath.isReachable() {
			return caskPath
		}

		if legacyCaskPath.isReachable() {
			return legacyCaskPath
		}

		return usrLocalPath
	}

	static var gsUtilEnvironment: [String: String]? {
		if caskPath.isReachable(),
		   legacyCaskPath.isReachable() {
			return cloudSDKVariable
		}
		return nil
	}
}
