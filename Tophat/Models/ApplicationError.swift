//
//  ApplicationError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-21.
//  Copyright © 2022 Shopify. All rights reserved.
//

enum ApplicationError: Error {
	case failedToReadBundleIdentifier
	case incompatibleDeviceType
	case missingProvisioningProfile
	case deviceNotProvisioned
	case applicationNotSigned
}
