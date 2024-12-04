//
//  AlertOptions.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit

public struct AlertOptions: Sendable {
	public let title: String
	public let content: String
	public let style: NSAlert.Style
	public let buttonText: String
}
