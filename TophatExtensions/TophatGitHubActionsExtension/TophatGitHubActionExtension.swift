//
//  TophatGitHubActionsExtension.swift
//  TophatGitHubActionsExtension
//
//  Created by Doan Thieu on 23/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import SwiftUI
import TophatKit

@main
struct TophatGitHubActionsExtension: TophatExtension, ArtifactProviding, SettingsProviding {
    static let title: LocalizedStringResource = "GitHub Actions"

    static var artifactProviders: some ArtifactProviders {
        GitHubActionsArtifactProvider()
    }

    static var settings: some View {
        SettingsView()
    }
}
