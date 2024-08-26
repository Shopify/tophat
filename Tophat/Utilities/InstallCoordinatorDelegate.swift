//
//  InstallCoordinatorDelegate.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

import TophatFoundation

protocol InstallCoordinatorDelegate: AnyObject {
	func installCoordinator(didSuccessfullyInstallAppForPlatform platform: Platform)
	func installCoordinator(didFailToInstallAppForPlatform platform: Platform?)
	func installCoordinator(didPromptToAllowUntrustedHost host: String) async -> HostTrustResult
}
