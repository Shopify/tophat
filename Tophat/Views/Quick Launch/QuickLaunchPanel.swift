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
						ForEach(Array(pinnedApplicationState.pinnedApplications.enumerated()), id: \.element.id) { index, app in
							Button {
								didSelect(app: app, index: index)
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

	private func didSelect(app: PinnedApplication, index: Int) {
		let launchContext = LaunchContext(appName: app.name, pinnedApplicationId: app.id)

		Task.detached(priority: .userInitiated) {
			let artifactSet = ArtifactSet(artifacts: app.artifacts)
			await launchApp?(artifactSet: artifactSet, on: app.platform, context: launchContext)
		}
	}
}
