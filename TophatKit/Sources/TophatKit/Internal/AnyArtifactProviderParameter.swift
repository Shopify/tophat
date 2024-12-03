//
//  AnyArtifactProviderParameter.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

protocol AnyArtifactProviderParameter: AnyObject {
	associatedtype Value: ArtifactProviderValue

	var key: String { get }
	var title: LocalizedStringResource { get }
	var description: LocalizedStringResource? { get }
	var prompt: LocalizedStringResource? { get }
	var help: LocalizedStringResource? { get }
}

extension AnyArtifactProviderParameter {
	var isOptional: Bool {
		Value.self is ExpressibleByNilLiteral.Type
	}
}
