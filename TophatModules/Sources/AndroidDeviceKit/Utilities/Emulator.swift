//
//  Emulator.swift
//  AndroidDeviceKit
//
//  Created by Jared Hendry on 2020-09-10.
//  Copyright © 2020 Shopify. All rights reserved.
//

import Foundation
import ShellKit

struct Emulator {
	static func start(name: String) throws {
		try run(command: .emulator(.startDevice(name: name)), log: log)
		// Artificially give Emulator time to communicate with adb
		// TODO: Figure out how Android Studio does it without sleeping
		sleep(5)
	}
}
