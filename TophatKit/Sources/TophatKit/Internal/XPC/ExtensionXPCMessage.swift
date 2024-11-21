//
//  ExtensionXPCMessage.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-24.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

@_spi(TophatKitInternal)
public protocol ExtensionXPCMessage: Codable {
	associatedtype Reply: Codable
}

extension ExtensionXPCMessage {
	var identifier: String {
		String(describing: Self.self)
	}
}
