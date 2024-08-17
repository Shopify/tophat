//
//  TophatServerDelegate.swift
//  TophatServer
//
//  Created by Lukas Romsicki on 2024-08-07.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

public protocol TophatServerDelegate: AnyObject {
	func server(didOpenURL url: URL)
}
