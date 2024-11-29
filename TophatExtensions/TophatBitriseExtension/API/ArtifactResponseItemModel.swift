//
//  ArtifactResponseItemModel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

struct ArtifactResponseItemModel: Codable {
	var artifactType: String
	var expiringDownloadURL: URL
	var fileSizeBytes: Int
	var isPublicPageEnabled: Bool
	var publicInstallPageURL: String
	var slug: String
	var title: String

	enum CodingKeys: String, CodingKey {
		case artifactType = "artifact_type"
		case expiringDownloadURL = "expiring_download_url"
		case fileSizeBytes = "file_size_bytes"
		case isPublicPageEnabled = "is_public_page_enabled"
		case publicInstallPageURL = "public_install_page_url"
		case slug
		case title
	}
}
