//
//  Logging.swift
//  TophatControlServices
//
//  Created by Lukas Romsicki on 2024-12-02.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Logging

// This will only be written to once, and only by the main app.
// Safe to ignore isolation checking unless the setup changes.
nonisolated(unsafe) public var log: Logger?
