//
//  TophatGitHubExtension.swift
//  TophatGitHubExtension
//
//  Created by Doan Thieu on 23/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import ExtensionFoundation
import Foundation
import SwiftUI
import TophatKit

@main
struct TophatGitHubExtension: TophatExtension, ArtifactProviding {
    static let title: LocalizedStringResource = "GitHub Action"

    static var artifactProviders: some ArtifactProviders {
        GitHubActionArtifactProvider()
    }
}
