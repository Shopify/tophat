//
//  TophatGitHubActionExtension.swift
//  TophatGitHubActionExtension
//
//  Created by Doan Thieu on 23/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import ExtensionKit
import SwiftUI
import TophatKit

@main
struct TophatGitHubActionExtension: TophatExtension, ArtifactProviding, SettingsProviding {
    static let title: LocalizedStringResource = "GitHub Action"

    static var artifactProviders: some ArtifactProviders {
        GitHubActionArtifactProvider()
    }

    static var settings: some View {
        SettingsView()
    }
}
