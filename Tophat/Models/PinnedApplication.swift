//
//  PinnedApplication.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

struct PinnedApplication: Identifiable, Codable {
	let id: String
	let name: String
	let platform: Platform
	let artifacts: [Artifact]
	let artifactProviderURL: URL?
	var icon: ApplicationIcon? = nil

	/// Creates a new pinned application.
	///
	/// Do not specify an `id` unless you are using this initializer to update an existing item via replace.
	/// User-created entries should only use auto-generated identifiers.
	///
	/// - Parameters:
	///   - id: The identifier of the pinned application, if used for updating purposes.
	///   - name: The name of the pinned application.
	///   - platform: The platform of the pinned application.
	///   - artifacts: The set of artifacts at which this pinned application can be found.
	init(id: String? = nil, name: String, platform: Platform, artifacts: [Artifact] = [], artifactProviderURL: URL? = nil) {
		self.id = id ?? UUID().uuidString
		self.name = name
		self.platform = platform
		self.artifacts = artifacts
		self.artifactProviderURL = artifactProviderURL
	}
}

extension ApplicationIcon: Codable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(url)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.init(url: try container.decode(URL.self))
	}
}
