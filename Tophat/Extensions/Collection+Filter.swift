//
//  Collection+Filter.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-03.
//  Copyright © 2022 Shopify. All rights reserved.
//

import TophatFoundation

extension Collection where Element == Device {
	func filter(by platform: Platform) -> [Device] {
		filter { $0.runtime.platform == platform }
	}
}
