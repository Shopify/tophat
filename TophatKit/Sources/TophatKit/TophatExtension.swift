//
//  TophatExtension.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import ExtensionFoundation
import ExtensionKit
import SwiftUI

/// The primary entry point for a Tophat extension.
///
/// Use this type to register the components of an extension to provide Tophat with
/// the functionality you implement.
public protocol TophatExtension: AppExtension {
	/// The human-readable name for the extension.
	static var title: LocalizedStringResource { get }

	/// The human-readable description for the extension.
	static var description: LocalizedStringResource? { get }
}

/// A type that supports registering build providers in a Tophat extension.
public protocol ArtifactProviding {
	associatedtype ExtensionArtifactProviders: ArtifactProviders

	/// A collection of `ArtifactProvider` objects that Tophat can use to retrieve
	/// artifacts from various sources.
	@ArtifactProvidersBuilder static var artifactProviders: ExtensionArtifactProviders { get }
}

/// A type that supports providing a settings view in a Tophat extension.
public protocol SettingsProviding {
	associatedtype SettingsBody: View

	/// The view to display in the Tophat Settings window to allow
	/// the extension to be configured.
	@ViewBuilder static var settings: SettingsBody { get }
}

public extension TophatExtension {
	var configuration: some AppExtensionConfiguration {
		ExtensionConfiguration(appExtension: self)
	}
}

public extension TophatExtension where Self: SettingsProviding {
	var configuration: AppExtensionSceneConfiguration {
		AppExtensionSceneConfiguration(
			PrimitiveAppExtensionScene(id: "TophatExtensionSettings") {
				Self.settings
					.scrollContentBackground(.hidden)
			},
			configuration: ExtensionConfiguration(appExtension: self)
		)
	}
}
