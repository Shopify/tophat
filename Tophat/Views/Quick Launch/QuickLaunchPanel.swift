//
//  QuickLaunchPanel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-12.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct QuickLaunchPanel: View {
	@Environment(\.launchApp) private var launchApp
	@EnvironmentObject private var pinnedApplicationState: PinnedApplicationState

	private let columns = Array(repeating: GridItem(.fixed(44), spacing: 14), count: 5)

	var body: some View {
		Panel {
			Group {
				if pinnedApplicationState.pinnedApplications.isEmpty {
					QuickLaunchEmptyState()
						.frame(minWidth: 0, maxWidth: .infinity)
				} else {
					LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
						ForEach(pinnedApplicationState.pinnedApplications) { app in
							Button {
								didSelect(app: app)
							} label: {
								QuickLaunchAppView(app: app)
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

	private func didSelect(app: PinnedApplication) {
		let launchContext = LaunchContext(appName: app.name, pinnedApplicationId: app.id)

		Task {
			await launchApp?(recipes: app.recipes, context: launchContext)
		}
	}
}
