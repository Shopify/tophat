//
//  InstallCoordinatorDelegate.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

import TophatFoundation

public protocol InstallCoordinatorDelegate: AnyObject {
	func installCoordinator(didSuccessfullyInstallAppForPlatform platform: Platform)
	func installCoordinator(didFailToInstallAppForPlatform platform: Platform?)
}
