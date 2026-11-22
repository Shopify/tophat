//
//  Aapt2.swift
//  AndroidDeviceKit
//
//  Created by Harley Cooper on 1/12/23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ShellKit
import RegexBuilder

final class Aapt2Error: Error {}

public struct Aapt2 {
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
			let output = try run(command: .aapt2(.dumpBadging(apkUrl: apkUrl)), log: log)

			if let match = output.firstMatch(of: packageNameRegex) {
				return String(match.1)
			}
		} catch {
			// Empty catch to avoid leaking the error
		}

		throw Aapt2Error()
	}

	public static func readAppName(apkUrl: URL) throws -> String? {
		do {
			let output = try run(command: .aapt2(.dumpBadging(apkUrl: apkUrl)), log: log)

			if let match = output.firstMatch(of: appNameRegex) {
				return String(match.1)
			}

			return nil
		} catch {
			throw Aapt2Error()
		}
	}

	public static func readIconPath(apkUrl: URL) throws -> String {
		guard
			let manifestTree = try? run(command: .aapt2(.dumpManifest(apkUrl: apkUrl)), log: log),
			let resourceID = Aapt2OutputParser.iconResourceID(inManifestTree: manifestTree),
			let resourceTable = try? run(command: .aapt2(.dumpResources(apkUrl: apkUrl)), log: log),
			let path = Aapt2OutputParser.iconPath(inResourceTable: resourceTable, resourceID: resourceID)
		else {
			throw Aapt2Error()
		}

		return path
	}
}
