//
//  String+Extensions.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

extension String {
	var indefiniteArticle: String {
		startsWithVowel ? "an" : "a"
	}
}

extension String {
	var isValidURL: Bool {
		if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
		   let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
			return match.range.length == self.utf16.count
		}

		return false
	}
}

extension Character {
	var isVowel: Bool {
		"aeiou".contains {
			String($0).compare(String(self).folding(options: .diacriticInsensitive, locale: nil), options: .caseInsensitive) == .orderedSame
		}
	}
}

extension StringProtocol {
	var startsWithVowel: Bool {
		first?.isVowel == true
	}
}
