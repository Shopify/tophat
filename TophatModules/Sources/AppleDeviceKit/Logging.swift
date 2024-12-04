//
//  Logging.swift
//  AppleDeviceKit
//
//  Created by Lukas Romsicki on 2022-01-02.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Logging

// This will only be written to once, and only by the main app.
// Safe to ignore isolation checking unless the setup changes.
nonisolated(unsafe) public var log: Logger?
