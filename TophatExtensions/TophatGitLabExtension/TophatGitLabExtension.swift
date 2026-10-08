//
//  TophatGitLabExtension.swift
//  TophatGitLabExtension
//
//  Created by Jonathan Seed on 2026-09-23.
//  Copyright © 2026 Shopify. All rights reserved.
//

import TophatKit
import SwiftUI

@main
struct TophatGitLabExtension: TophatExtension, ArtifactProviding, SettingsProviding {
    static let title: LocalizedStringResource = "GitLab"

    static var artifactProviders: some ArtifactProviders {
        GitLabArtifactProvider()
    }

    static var settings: some View {
        SettingsView()
    }
}
