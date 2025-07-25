//
//  TophatExtension.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import ExtensionFoundation
@_spi(TophatKitInternal) import TophatKit

struct TophatExtension: Sendable {
	let identity: AppExtensionIdentity
	let specification: ExtensionSpecification
}

extension TophatExtension: Identifiable {
	var id: String {
		identity.bundleIdentifier
	}
}

extension TophatExtension: Equatable {
	static func == (lhs: TophatExtension, rhs: TophatExtension) -> Bool {
		lhs.id == rhs.id
	}
}

extension TophatExtension: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension TophatExtension: Comparable {
	static func < (lhs: TophatExtension, rhs: TophatExtension) -> Bool {
		String(localized: lhs.specification.title)
			.caseInsensitiveCompare(String(localized: rhs.specification.title)) == .orderedAscending
	}
}
