//
//  QuickLaunchPanel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-12.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import SwiftData
import TophatFoundation

struct QuickLaunchPanel: View {
	@Environment(\.launchApp) private var launchApp

	@Query(sort: \QuickLaunchEntry.order)
	var entries: [QuickLaunchEntry]

	private let columns = Array(repeating: GridItem(.fixed(44), spacing: 14), count: 5)

	var body: some View {
		Panel {
			Group {
				if entries.isEmpty {
					QuickLaunchEmptyState()
						.frame(minWidth: 0, maxWidth: .infinity)
				} else {
					LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
						ForEach(entries) { entry in
							Button {
								Task { await launchApp?(quickLaunchEntry: entry) }
							} label: {
								QuickLaunchEntryView(entry: entry)
							}
							.buttonStyle(.plain)
						}
					}
					.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				}
			}
			.padding([.top, .horizontal], 16)
			.padding(.bottom, 12)
		}
	}
}
