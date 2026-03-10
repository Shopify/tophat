//
//  QuickLaunchEntry+InstallRecipe.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2026-03-09.
//  Copyright © 2026 Shopify. All rights reserved.
//

import TophatFoundation

extension QuickLaunchEntry {
	var installRecipes: [InstallRecipe] {
		recipes.map { source in
			InstallRecipe(
				source: .artifactProvider(
					metadata: ArtifactProviderMetadata(
						id: source.artifactProviderID,
						parameters: source.artifactProviderParameters
					)
				),
				launchArguments: source.launchArguments,
				deviceInfo: .hinted(InstallRecipe.DeviceHints(
					platformHint: source.platformHint,
					destinationHint: source.destinationHint
				))
			)
		}
	}
}
