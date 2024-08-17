//
//  TophatInterProcessNotification.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

/// The protocol you use to define notifications to be sent between Tophat processes.
public protocol TophatInterProcessNotification<Payload> {
	associatedtype Payload: Codable

	static var name: String { get }
	var payload: Payload { get }
}
