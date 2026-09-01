//
//  TophatXcodeCloudExtension.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import SwiftUI
import TophatKit

@main
struct TophatXcodeCloudExtension: TophatExtension, ArtifactProviding, SettingsProviding {
	static let title: LocalizedStringResource = "Xcode Cloud"

	static var artifactProviders: some ArtifactProviders {
		XcodeCloudArtifactProvider()
	}

	static var settings: some View {
		SettingsView()
	}
}
