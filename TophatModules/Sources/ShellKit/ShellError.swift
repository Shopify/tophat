//
//  ShellError.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2022-11-22.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

public struct ShellError: Error {
	/// The termination status of the command that was run
	public let terminationStatus: Int32

	/// The raw error buffer data, as returned through `STDERR`
	public let errorData: Data

	/// The raw output buffer data, as retuned through `STDOUT`
	public let outputData: Data

	/// The error message as a UTF8 string, as returned through `STDERR`
	public var message: String {
		errorData.utf8String
	}

	/// The output of the command as a UTF8 string, as returned through `STDOUT`
	public var output: String {
		outputData.utf8String
	}
}
