//
//  TophatBaseExtension.swift
//  TophatBaseExtension
//
//  Created by Lukas Romsicki on 2024-10-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatKit
import SwiftUI

@main
struct TophatCoreExtension: TophatExtension, ArtifactProviding {
	static let title: LocalizedStringResource = "Core Features"
	static let description: LocalizedStringResource? = "Built-in Tophat functionality"

	static var artifactProviders: some ArtifactProviders {
		HTTPArtifactProvider()
		ShellScriptArtifactProvider()
	}
}
