//
//  ShellCommand.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2022-01-02.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

public enum Executable {
	case name(String)
	case url(URL)
}

public protocol ShellCommand {
	/// Name of the command, finding it in the user's PATH if the URL is nil
	var executable: Executable { get }

	/// Environment variables to pass to the command.
	var environment: [String: String] { get }

	/// The arguments to pass to the command.
	var arguments: [String] { get }
}

public extension ShellCommand {
	var environment: [String: String] {
		[:]
	}
}

internal extension ShellCommand {
	private var formattedEnvironmentVariables: [String] {
		environment.map { key, value in "\(key)=\"\(value)\"" }
	}

	var string: String {
		let executableString = {
			switch executable {
			case .url(let url):
				return url.path(percentEncoded: false)
			case .name(let name):
				return name
			}
		}()

		let executablePath = executableString.contains(" ") ? executableString.wrappedInQuotationMarks() : executableString

		return [formattedEnvironmentVariables, [executablePath], arguments].flatMap { $0 }.joined(separator: " ")
	}
}
