//
//  RetrieveArtifactMessage.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-09.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

@_spi(TophatKitInternal)
public struct RetrieveArtifactMessage: ExtensionXPCMessage {
	public typealias Reply = ArtifactProviderResultContainer

	let providerID: String
	let parameters: [String: String]

	public init(providerID: String, parameters: [String: String]) {
		self.providerID = providerID
		self.parameters = parameters
	}
}
