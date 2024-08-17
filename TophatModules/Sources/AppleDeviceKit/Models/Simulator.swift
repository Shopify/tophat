//
//  Simulator.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

struct Simulator {
	let udid: String
	let runtimeIdentifier: String
	let name: String
	let rawState: State

	enum State: String {
		case booted = "Booted"
		case shutdown = "Shutdown"
	}
}
