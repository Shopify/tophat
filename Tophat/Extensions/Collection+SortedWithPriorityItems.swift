//
//  Collection+SortedWithPriorityItems.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2025-07-25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation

extension Collection where Element: Equatable, Element: Comparable {
	func sorted(priorityItems: [Element]) -> [Element] {
		return sorted { a, b in
			let aIsPriority = priorityItems.contains(a)
			let bIsPriority = priorityItems.contains(b)

			return aIsPriority != bIsPriority ? aIsPriority : a < b
		}
	}
}
