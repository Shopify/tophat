//
//  Data+UTF8String.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2022-11-22.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

extension Data {
	var utf8String: String {
		guard let output = String(data: self, encoding: .utf8) else {
			return ""
		}

		guard !output.hasSuffix("\n") else {
			let endIndex = output.index(before: output.endIndex)
			return String(output[..<endIndex])
		}

		return output
	}
}
