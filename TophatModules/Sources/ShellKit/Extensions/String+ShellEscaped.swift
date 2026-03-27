//
//  String+ShellEscaped.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2026-03-27.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

public extension String {
	/// Escapes a string for safe inclusion as a single argument in a shell command.
	/// Uses single-quote wrapping, which prevents interpretation of all special characters.
	func shellEscaped() -> String {
		"'" + self.replacingOccurrences(of: "'", with: "'\\''") + "'"
	}

	/// Whether the string is safe for use as a shell argument.
	var isSafeShellArgument: Bool {
		allSatisfy { $0.isLetter || $0.isNumber || safeShellCharacters.contains($0) }
	}
}

private let safeShellCharacters: Set<Character> = ["-", "_", ".", "/", ":", "=", "@", "%", "+", " ", ","]
