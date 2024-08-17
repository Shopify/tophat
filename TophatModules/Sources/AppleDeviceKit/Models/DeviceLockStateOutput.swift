//
//  DeviceLockStateOutput.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2023-09-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

struct DeviceLockStateOutput: Decodable {
	let result: Result

	struct Result: Decodable {
		let deviceIdentifier: String
		let passcodeRequired: Bool
		let unlockedSinceBoot: Bool
	}
}
