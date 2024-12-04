//
//  TophatCtlSymbolicLinkManager.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

@MainActor final class TophatCtlSymbolicLinkManager: ObservableObject {
	private let utilityName = "tophatctl"

	func install() async {
		guard let destinationPath = destinationPath else {
			return
		}

		await runElevatedShellCommand(string: installCommand(destinationPath: destinationPath))
		objectWillChange.send()
	}

	func uninstall() async {
		await runElevatedShellCommand(string: uninstallCommand)
		objectWillChange.send()
	}

	var isInstalled: Bool {
		FileManager.default.isReadableFile(atPath: sourcePath)
	}

	private func runElevatedShellCommand(string: String) async {
		let source = "do shell script \(string.wrappedInQuotationMarks()) with administrator privileges"

		await withCheckedContinuation { continuation in
			Task.detached {
				guard let script = NSAppleScript(source: source) else {
					return
				}

				var error: NSDictionary?
				script.executeAndReturnError(&error)
				continuation.resume()
			}
		}
	}

	private func installCommand(destinationPath: String) -> String {
		"mkdir -p /usr/local/bin && ln -sf '\(destinationPath)' '\(sourcePath)'"
	}

	private var uninstallCommand: String {
		"rm '\(sourcePath)'"
	}

	private var destinationPath: String? {
		Bundle.main.path(forAuxiliaryExecutable: utilityName)
	}

	private var sourcePath: String {
		"/usr/local/bin/\(utilityName)"
	}
}
