//
//  PinnedApplicationState.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-12.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

final class PinnedApplicationState: ObservableObject {
	@CodableAppStorage("PinnedApplications") var pinnedApplications: [PinnedApplication] = [] {
		willSet {
			DispatchQueue.main.async {
				// Temporary workaround since the current implementation of CodableAppStorage
				// isn't yet able to forward objectWillChange to its parent like AppStorage does.
				self.objectWillChange.send()
			}
		}
	}
}
