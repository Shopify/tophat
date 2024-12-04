//
//  AsyncParsableCommand+Extensions.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import AppKit
import ArgumentParser

extension AsyncParsableCommand {
	func checkIfHostAppIsRunning() {
		if !NSRunningApplication.isTophatRunning {
			print("Warning: Tophat must be running for this command to succeed, but it is not running.")
		}
	}
}
