//
//  DeviceError+StyledAlertError.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-09-13.
//  Copyright © 2023 Shopify. All rights reserved.
//

import AppKit
import TophatFoundation

extension DeviceError: StyledAlertError {
	public var alertStyle: NSAlert.Style? {
		switch self {
		case .failedToLaunchApp(_, reason: .requiresManualProfileTrust, _):
			return .informational
		default:
			return nil
		}
	}
}
