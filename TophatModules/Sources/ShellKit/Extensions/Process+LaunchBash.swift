//
//  Process+LaunchBash.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2022-11-22.
//  Copyright © 2022 Shopify. All rights reserved.
//
//  Based on the implementation of ShellOut:
//  https://github.com/JohnSundell/ShellOut/blob/d3db50b62a86b18f88f5de38cae5f3d80617d555/Sources/ShellOut.swift
//

import Foundation

public typealias StandardOutputHandler = @Sendable (String) -> Void
public typealias StandardErrorHandler = @Sendable (String) -> Void

extension Process {
	@discardableResult func launchBash(
		command: String,
		standardOutputHandler: StandardOutputHandler? = nil,
		standardErrorHandler: StandardErrorHandler? = nil
	) throws -> String {
		launchPath = "/bin/bash"
		arguments = ["-c", command]

		// Because FileHandle's readabilityHandler might be called from a
		// different queue from the calling queue, avoid a data race by
		// protecting reads and writes to outputData and errorData on
		// a single dispatch queue.
		let outputQueue = DispatchQueue(label: "bash-output-queue")

		var outputData = Data()
		var errorData = Data()

		let outputPipe = Pipe()
		standardOutput = outputPipe

		let errorPipe = Pipe()
		standardError = errorPipe

		outputPipe.fileHandleForReading.readabilityHandler = { handler in
			let data = handler.availableData
			outputQueue.async {
			   outputData.append(data)

			   if !data.isEmpty {
				   standardOutputHandler?(data.utf8String)
			   }
		   }
		}

		errorPipe.fileHandleForReading.readabilityHandler = { handler in
			let data = handler.availableData
			outputQueue.async {
				errorData.append(data)

				if !data.isEmpty {
					standardErrorHandler?(data.utf8String)
				}
			}
		}

		launch()
		waitUntilExit()

		outputPipe.fileHandleForReading.readabilityHandler = nil
		errorPipe.fileHandleForReading.readabilityHandler = nil

		// Block until all writes have occurred to outputData and errorData,
		// and then read the data back out.
		return try outputQueue.sync {
			if terminationStatus != 0 {
				throw ShellError(
					terminationStatus: terminationStatus,
					errorData: errorData,
					outputData: outputData
				)
			}

			return outputData.utf8String
		}
	}
}
