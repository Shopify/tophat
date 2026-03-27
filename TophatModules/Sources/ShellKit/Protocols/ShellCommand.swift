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

/// A shell command argument with explicit control over escaping.
public enum ShellArgument: Sendable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
	/// An argument that is shell-escaped before execution.
	case safe(String)
	/// An argument passed verbatim to the shell, such as redirects or pipes.
	case unsafe(String)

	public init(stringLiteral value: String) {
		self = .safe(value)
	}

	public init(_ value: String) {
		self = .safe(value)
	}
}

public protocol ShellCommand: Sendable {
	/// Name of the command, finding it in the user's PATH if the URL is nil
	var executable: Executable { get }

	/// Environment variables to pass to the command.
	var environment: [String: String] { get }

	/// The arguments to pass to the command.
	var arguments: [ShellArgument] { get }
}

public extension ShellCommand {
	var environment: [String: String] {
		[:]
	}
}

internal extension ShellCommand {
	private var formattedEnvironmentVariables: [String] {
		environment.map { key, value in "\(key)=\(value.shellEscaped())" }
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

		let formattedArguments = arguments.map { argument in
			switch argument {
			case .safe(let value):
				return value.shellEscaped()
			case .unsafe(let value):
				return value
			}
		}

		return [formattedEnvironmentVariables, [executableString.shellEscaped()], formattedArguments].flatMap { $0 }.joined(separator: " ")
	}
}
