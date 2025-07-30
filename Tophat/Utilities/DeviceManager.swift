//
//  DeviceManager.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-28.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

/// The `DeviceManager` coordinates between different device providers. Device providers
/// "plug-in" to the `DeviceManager` such that it is the sole entity responsible for retrieving
/// and managing devices in a platform-agnostic manner.
@MainActor @Observable final class DeviceManager {
	private let deviceProviders: [DeviceProvider.Type]

	/// A collection of all devices from all sources.
	private(set) var devices: [Device] = []

	init(sources: [DeviceProvider.Type]) {
		self.deviceProviders = sources
	}

	private(set) var isLoading = false

	/// Loads all available devices into `devices`.
	func loadDevices() async {
		guard !isLoading else {
			log.info("Not loading devices because they are already being loaded")
			return
		}

		log.info("Loading devices")
		isLoading = true

		defer {
			isLoading = false
			log.info("Finished loading devices")
		}

		self.devices = await withTaskGroup(of: [Device].self) { group in
			var devices: [Device] = []

			deviceProviders.forEach { provider in
				group.addTask {
					return await provider.all
				}
			}

			for await deviceSubset in group {
				devices.append(contentsOf: deviceSubset)
			}

			return devices.sortedByLogicalPriority()
		}
	}
}

private extension Platform {
	var sortPriority: Int {
		switch self {
			case .iOS:
				return 0
			case .watchOS:
				return 2
			case .tvOS:
				return 3
			case .android:
				return 1
			default:
				return 4
		}
	}
}

private extension Connection {
	var sortPriority: Int {
		switch self {
			case .direct:
				return 0
			case .network:
				return 1
			case .internal:
				return 2
		}
	}
}

private extension Array<Device> {
	/// Sorts an array of devices in an order that is ideal for display.
	///
	/// This function uses the `sortPriority` defined above in this file to sort items in
	/// the following order:
	///
	/// - Connection (see `Connection.sortPriority` above)
	/// - Platform (see `Platform.sortPriority` above)
	/// - Name (alphabetical matching Xcode)
	/// - Runtime Version
	///
	/// - Returns: A sorted array of devices.
	func sortedByLogicalPriority() -> [Element] {
		sorted { first, second in
			if first.connection.sortPriority != second.connection.sortPriority {
				return first.connection.sortPriority < second.connection.sortPriority
			}

			if first.runtime.platform.sortPriority != second.runtime.platform.sortPriority {
				return first.runtime.platform.sortPriority < second.runtime.platform.sortPriority
			}

			let nameComparison = first.name.compare(second.name)

			if nameComparison != .orderedSame {
				return nameComparison == .orderedAscending
			}

			return first.runtime.version.description
				.caseInsensitiveCompare(second.runtime.version.description) == .orderedAscending
		}
	}
}
