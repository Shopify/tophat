//
//  Platform+ExpressibleByArgument.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import TophatFoundation
import ArgumentParser

extension Platform: ExpressibleByArgument {
	public init?(argument: String) {
		self.init(rawValue: argument.lowercased())
	}
}
