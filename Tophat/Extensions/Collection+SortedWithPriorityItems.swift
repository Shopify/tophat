//
//  Collection+SortedWithPriorityItems.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2025-07-25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation

extension Collection where Element: Equatable, Element: Comparable, Element: Hashable {
	func sorted(priorityItems: [Element]) -> [Element] {
		let prioritySet = Set(priorityItems)

		return sorted { a, b in
			let aIsPriority = prioritySet.contains(a)
			let bIsPriority = prioritySet.contains(b)

			return aIsPriority != bIsPriority ? aIsPriority : a < b
		}
	}
}
