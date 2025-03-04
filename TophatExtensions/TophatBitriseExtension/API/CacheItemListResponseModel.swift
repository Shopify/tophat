//
//  CacheItemListResponseModel.swift
//  Tophat
//
//  Created by Yasmin Benatti on 2025-03-04.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation

struct CacheItemListResponseModel: Decodable {
	var data: [CacheItemResponseModel]
	var paging: [String: String]
}
