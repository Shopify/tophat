//
//  LaunchAtLoginController.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-31.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import ServiceManagement

final class LaunchAtLoginController: ObservableObject {
	var isEnabled: Bool {
		get {
			SMAppService.mainApp.status == .enabled
		}
		set {
			do {
				if newValue {
					if SMAppService.mainApp.status == .enabled {
						// Re-register if set to true multiple times.
						try? SMAppService.mainApp.unregister()
					}

					try SMAppService.mainApp.register()
				} else {
					try SMAppService.mainApp.unregister()
				}
			} catch {
				log.error("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
			}

			objectWillChange.send()
		}
	}
}
