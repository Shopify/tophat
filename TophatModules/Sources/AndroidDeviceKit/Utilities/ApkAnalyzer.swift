//
//  ApkAnalyzer.swift
//  AndroidDeviceKit
//
//  Created by Jared Hendry on 2020-09-10.
//  Copyright © 2020 Shopify. All rights reserved.
//

import Foundation
import ShellKit

class ApkAnalyzerError: Error {}

public struct ApkAnalyzer {
	public static func getIconPath(apkUrl: URL) throws -> String {
		do {
			return try run(command: .apkAnalyzer(.icon(apkUrl: apkUrl)), log: log)
		} catch {
			throw ApkAnalyzerError()
		}
	}
}
