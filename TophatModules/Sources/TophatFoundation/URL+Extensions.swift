//
//  URL+Extensions.swift
//  Tophat
//
//  Created by Harley Cooper on 1/19/23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

public extension URL {
	func appending<S>(paths: [S], directoryHint: URL.DirectoryHint = .inferFromPath) -> URL where S: StringProtocol {
		return paths.reduce(self) { $0.appending(path: $1, directoryHint: directoryHint) }
	}

	func isReachable() -> Bool {
		guard let result = try? checkResourceIsReachable() else {
			return false
		}

		return result
	}
}
