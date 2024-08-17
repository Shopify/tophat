//
//  Device.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2023-09-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

/// An entity that can be deleted from disk.
public protocol Deletable {
	/// Deletes the item from disk.
	func delete() async throws
}
