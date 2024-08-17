//
//  StyledAlertError.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2023-09-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import AppKit

/// An error that can be represented using an alert with a specific style.
public protocol StyledAlertError {
	/// The style of alert to use.
	var alertStyle: NSAlert.Style? { get }
}
