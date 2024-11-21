//
//  Collection+Safe.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2024-09-27.
//  Copyright © 2024 Shopify. All rights reserved.
//

public extension Collection {
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
