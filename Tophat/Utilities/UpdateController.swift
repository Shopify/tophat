//
//  UpdateController.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-08-30.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import Observation
import Combine
import Sparkle

@Observable final class UpdateController {
	private unowned let updater: SPUUpdater

	@ObservationIgnored private var cancellables = Set<AnyCancellable>()

	private(set) var canCheckForUpdates = false
	private(set) var isCheckingForUpdates = false

	var isAutomaticUpdateCheckEnabled: Bool {
		didSet {
			if isAutomaticUpdateCheckEnabled != oldValue {
				updater.automaticallyChecksForUpdates = isAutomaticUpdateCheckEnabled
			}
		}
	}

	var isAutomaticUpdateDownloadEnabled: Bool {
		didSet {
			if isAutomaticUpdateDownloadEnabled != oldValue {
				updater.automaticallyDownloadsUpdates = isAutomaticUpdateDownloadEnabled
			}
		}
	}

	init(updater: SPUUpdater) {
		self.updater = updater
		self.isAutomaticUpdateCheckEnabled = updater.automaticallyChecksForUpdates
		self.isAutomaticUpdateDownloadEnabled = updater.automaticallyDownloadsUpdates

		updater
			.publisher(for: \.automaticallyChecksForUpdates)
			.assign(to: \.isAutomaticUpdateCheckEnabled, on: self)
			.store(in: &cancellables)

		updater
			.publisher(for: \.automaticallyDownloadsUpdates)
			.assign(to: \.isAutomaticUpdateDownloadEnabled, on: self)
			.store(in: &cancellables)

		updater
			.publisher(for: \.canCheckForUpdates)
			.assign(to: \.canCheckForUpdates, on: self)
			.store(in: &cancellables)

		updater
			.publisher(for: \.sessionInProgress)
			.assign(to: \.isCheckingForUpdates, on: self)
			.store(in: &cancellables)
	}

	func checkForUpdates() {
		updater.checkForUpdates()
	}
}
