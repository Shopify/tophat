//
//  Aapt.swift
//  AndroidDeviceKit
//
//  Created by Harley Cooper on 1/12/23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ShellKit
import RegexBuilder

final class AaptError: Error {}

public struct Aapt {
	nonisolated(unsafe) private static let appNameRegex = Regex {
		"application-label:'"
		Capture {
			OneOrMore(CharacterClass(.anyNonNewline))
		}
		"'"
	}

	nonisolated(unsafe) private static let packageNameRegex = Regex {
		"package: name='"
		Capture {
			OneOrMore(.anyNonNewline.subtracting(.whitespace), .reluctant)
		}
		"'"
	}

	public static func readPackageName(apkUrl: URL) throws -> String {
		do {
			let output = try run(command: .aapt(.dumpBadging(apkUrl: apkUrl)), log: log)
			if let match = output.firstMatch(of: packageNameRegex) {
				return String(match.1)
			}
		} catch {
			// Empty catch to avoid leaking the error
		}
		throw AaptError()
	}

	public static func readAppName(apkUrl: URL) throws -> String? {
		do {
			let output = try run(command: .aapt(.dumpBadging(apkUrl: apkUrl)), log: log)
			if let match = output.firstMatch(of: appNameRegex) {
				return String(match.1)
			}
			return nil
		} catch {
			throw AaptError()
		}
	}
}
