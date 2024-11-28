//
//  ArtifactListResponseModel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

struct ArtifactListResponseModel: Codable {
	var data: [ArtifactListElementResponseModel]
}
