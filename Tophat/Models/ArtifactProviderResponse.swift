//
//  ArtifactProviderResponse.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-03-16.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

struct ArtifactProviderResponse: Decodable {
	let name: String
	let platform: Platform
	let virtual: URL?
	let physical: URL?
}
