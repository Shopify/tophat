//
//  ShellCommandRunner.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2022-01-02.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import Logging

/// Runs a shell command using Bash and returns the messages printed to standard output.
/// - Parameters:
///   - command: The ``ShellCommand`` to run.
///   - log: The logger to use when printing log messages.
///   - standardOutputHandler: Optional closure that runs when a new message is printed to standard output.
///   - standardErrorHandler: Optional closure that runs the a new message is printed to standard error.
/// - Throws: An instance of ``ShellError`` describing the nature of the error.
/// - Returns: A string containing the output of the command.
@discardableResult
public func run(
	command: ShellCommand,
	log: Logger? = nil,
	standardOutputHandler: StandardOutputHandler? = nil,
	standardErrorHandler: StandardErrorHandler? = nil
) throws -> String {
	let process = Process()

	log?.info("Executing command: \(command.string)")

	do {
		return try process.launchBash(
			command: command.string,
			standardOutputHandler: standardOutputHandler,
			standardErrorHandler: standardErrorHandler
		)

	} catch let error as ShellError {
		log?.error(
			"An error occurred while executing command: \(error.message)",
			metadata: [
				"command": .string(command.string),
				"code": .stringConvertible(error.terminationStatus)
			]
		)

		throw error
	}
}

/// Possible shell command output.
public enum ShellOutput {
	case standardOutput(String)
	case standardError(String)
}

/// Asynchronous version of `run` that returns an `AsyncThrowingStream` that contains the output of the command.
/// - Parameters:
///   - command: The ``ShellCommand`` to run.
///   - log: The logger to use when printing log messages.
/// - Returns: An `AsyncThrowingStream` containing the messages printed to standard output and standard error.
public func runAsync(command: ShellCommand, log: Logger? = nil) -> AsyncThrowingStream<ShellOutput, Error> {
	AsyncThrowingStream { continuation in
		let standardOutputHandler: StandardOutputHandler = { output in
			continuation.yield(.standardOutput(output))
		}

		let standardErrorHandler: StandardErrorHandler = { output in
			continuation.yield(.standardError(output))
		}

		Task {
			do {
				try run(
					command: command,
					log: log,
					standardOutputHandler: standardOutputHandler,
					standardErrorHandler: standardErrorHandler
				)

				continuation.finish()

			} catch {
				continuation.finish(throwing: error)
			}
		}
	}
}
