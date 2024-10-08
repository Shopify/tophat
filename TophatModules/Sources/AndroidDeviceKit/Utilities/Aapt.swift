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

class AaptError: Error {}

public struct Aapt {
	private static let appNameRegex = Regex {
		"application-label:'"
		Capture {
			OneOrMore(CharacterClass(.anyNonNewline))
		}
		"'"
	}

	public static func readAppName(apkUrl: URL) throws -> String? {
		do {
			let output = try run(command: .aapt(.name(apkUrl: apkUrl)), log: log)
			if let match = output.firstMatch(of: appNameRegex) {
				return String(match.1)
			}
			return nil
		} catch {
			throw AaptError()
		}
	}
}
