//
//  ApplicationError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-21.
//  Copyright © 2022 Shopify. All rights reserved.
//

import TophatFoundation

enum ApplicationError: Error {
	case failedToReadBundleIdentifier
	case incompatible(application: Application, device: Device)
	case missingProvisioningProfile
	case deviceNotProvisioned
	case applicationNotSigned
}
