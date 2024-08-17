//
//  URL+ExpressibleByArgument.swift
//  tophatctl
//
//  Created by Lukas Romsicki on 2023-01-26.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ArgumentParser

extension URL: ExpressibleByArgument {
	public init?(argument: String) {
		guard let temporaryURL = URL(string: argument) else {
			return nil
		}

		if temporaryURL.scheme == nil {
			self.init(filePath: NSString(string: argument).expandingTildeInPath)
		} else {
			self = temporaryURL
		}
	}
}
