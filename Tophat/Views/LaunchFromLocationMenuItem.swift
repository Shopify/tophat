//
//  LaunchFromLocationMenuItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-20.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation
import UniformTypeIdentifiers

struct LaunchFromLocationMenuItem: View {
	@Environment(\.launchApp) var launchApp
	@Environment(\.showingAlternateItems) var showingAlternateItems

	@State private var launchFromURLPanelPresented = false

	var body: some View {
		Button(label, action: didPerformPrimaryAction)
			.buttonStyle(.menuItem(activatesApplication: true, blinks: true))
			.floatingPanel(isPresented: $launchFromURLPanelPresented) {
				LaunchFromURLPanel()
					// Panels are created in a new SwiftUI context (NSHostingView) so we need to forward
					// whatever environment we need.
					.environment(\.launchApp, launchApp)
			}
	}

	private var label: String {
		showingAlternateItems ? "Launch App from Location…" : "Launch App from File…"
	}

	private func didPerformPrimaryAction() {
		showingAlternateItems ? openLaunchFromURLPanel() : openFilePicker()
	}

	private func openFilePicker() {
		let panel = NSOpenPanel()

		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.prompt = "Launch"
		panel.allowedContentTypes = ArtifactFileFormat.contentTypes

		guard panel.runModal() == .OK, let url = panel.url else {
			return
		}

		Task {
			await launchApp?(artifactURL: url)
		}
	}

	private func openLaunchFromURLPanel() {
		launchFromURLPanelPresented = true
	}
}

private extension ArtifactFileFormat {
	static var contentTypes: [UTType] {
		allCases.compactMap { item in
			item.type
		}
	}

	var type: UTType? {
		switch self {
			case .zip:
				return .zip
			case .applicationBundle:
				return .applicationBundle
			case .appStorePackage, .androidPackage:
				return .init(filenameExtension: pathExtension)
		}
	}
}
