//
//  AppIconExtracting.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2026-03-30.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

public protocol AppIconExtracting: Sendable {
	func extractAppIcon(application: Application) async throws -> URL
}
