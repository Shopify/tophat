//
//  CiArtifactResponseItemModel.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

struct CiArtifactResponseItemModel: Decodable {
	var id: String
	var attributes: Attributes?

	struct Attributes: Decodable {
		var fileName: String?
		var fileSize: Int?
		var fileType: String?
		var downloadURL: URL?

		enum CodingKeys: String, CodingKey {
			case fileName
			case fileSize
			case fileType
			case downloadURL = "downloadUrl"
		}
	}
}

extension CiArtifactResponseItemModel {
	/// The products that `xcodebuild` wrote to its build directory, which contain the
	/// application bundle that can be installed onto a simulator.
	static let buildProductsFileType = "XCODEBUILD_PRODUCTS"

	/// An export of an archive, which contains the App Store package to install onto a
	/// device. A build action produces one export for each configured export method.
	static let archiveExportFileType = "ARCHIVE_EXPORT"
}
