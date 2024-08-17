//
//  Array+JoinedWithSpaces.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

extension Array where Element == String? {
	func joinedWithSpaces() -> String {
		compactMap { $0 }.joined(separator: " ")
	}
}
