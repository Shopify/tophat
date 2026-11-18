//
//  CiArtifactListResponseModel.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

struct CiArtifactListResponseModel: Decodable {
	var data: [CiArtifactResponseItemModel]
}
