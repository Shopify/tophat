//
//  LaunchAppAction.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-20.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct LaunchAppAction {
	private let installCoordinator: InstallCoordinator

	init(installCoordinator: InstallCoordinator) {
		self.installCoordinator = installCoordinator
	}

	func callAsFunction(artifactURL: URL, context: LaunchContext? = nil) async {
		do {
			try await installCoordinator.launch(artifactURL: artifactURL, context: context)
		} catch {
			ErrorNotifier().notify(error: error)
		}
	}

	func callAsFunction(artifactProviderURL: URL, context: LaunchContext? = nil) async {
		do {
			try await installCoordinator.launch(artifactProviderURL: artifactProviderURL, context: context)
		} catch {
			ErrorNotifier().notify(error: error)
		}
	}

	func callAsFunction(artifactSet: ArtifactSet, on platform: Platform, context: LaunchContext? = nil) async {
		do {
			try await installCoordinator.launch(artifactSet: artifactSet, on: platform, context: context)
		} catch {
			ErrorNotifier().notify(error: error)
		}
	}
}

private struct LaunchAppKey: EnvironmentKey {
	static var defaultValue: LaunchAppAction?
}

extension EnvironmentValues {
	var launchApp: LaunchAppAction? {
		get { self[LaunchAppKey.self] }
		set { self[LaunchAppKey.self] = newValue }
	}
}
