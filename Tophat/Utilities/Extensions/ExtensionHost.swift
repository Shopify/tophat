//
//  ExtensionHost.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import ExtensionFoundation
@_spi(TophatKitInternal) import TophatKit

@MainActor @Observable final class ExtensionHost {
	private(set) var availableExtensions: [TophatExtension] = []

	func discover() {
		Task {
			do {
				let sequence = try AppExtensionIdentity.matching(
					appExtensionPointIDs: "com.shopify.Tophat.extension"
				)

				for await identities in sequence {
					self.availableExtensions = try await withThrowingTaskGroup(of: TophatExtension.self, returning: [TophatExtension].self) { group in
						for identity in identities {
							group.addTask {
								let specification = try await identity.withXPCSession { session in
									return try await session.send(FetchExtensionSpecificationMessage())
								}

								return TophatExtension(identity: identity, specification: specification)
							}
						}

						var specifications: [TophatExtension] = []

						for try await specification in group {
							specifications.append(specification)
						}

						let coreExtensions = specifications.filter { specification in
							specification.id == "com.shopify.Tophat.TophatCoreExtension"
						}

						return specifications.sorted(priorityItems: coreExtensions)
					}
				}
			} catch {
				print("Failed to discover extensions: \(error)")
			}
		}
	}
}
