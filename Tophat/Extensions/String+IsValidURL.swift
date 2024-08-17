//
//  String+IsValidURL.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

extension String {
	var isValidURL: Bool {
		if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
		   let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
			return match.range.length == self.utf16.count
		}

		return false
	}
}
