//
//  TophatBitriseExtension.swift
//  TophatBitriseExtension
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatKit
import SwiftUI

@main
struct TophatBitriseExtension: TophatExtension, ArtifactProviding, SettingsProviding {
	static let title: LocalizedStringResource = "Bitrise"

	static var artifactProviders: some ArtifactProviders {
		BasicArtifactProvider()
		BranchArtifactProvider()
	}

	static var settings: some View {
		SettingsView()
	}
}
