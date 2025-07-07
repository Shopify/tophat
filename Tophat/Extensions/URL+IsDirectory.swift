//
//  URL+IsDirectory.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2025-06-26.
//  Copyright © 2025 Shopify. All rights reserved.
//

import Foundation

extension URL {
	var isDirectory: Bool {
		(try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
	}
}
