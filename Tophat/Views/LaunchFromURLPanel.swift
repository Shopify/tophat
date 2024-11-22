//
//  LaunchFromURLPanel.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct LaunchFromURLPanel: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.customWindowPresentation) private var customWindowPresentation
	@Environment(\.launchApp) private var launchApp

	@State private var text = ""

	var body: some View {
		VStack(spacing: 12) {
			TextField("URL", text: $text, prompt: Text("Artifact URL"))
				.textFieldStyle(.plain)
				.font(.title)
				.foregroundColor(colorScheme == .dark ? .white : .primary)

			HStack(alignment: .firstTextBaseline) {
				Spacer()

				Button("Cancel") {
					customWindowPresentation?.dismiss()
					text = ""
				}

				Button("Launch") {
					if let url = URL(string: text) {
						text = ""

						Task(priority: .userInitiated) {
							await launchApp?(artifactURL: url)
						}
					}

					customWindowPresentation?.dismiss()
				}
				.keyboardShortcut(.defaultAction)
				.disabled(!text.isValidURL)
			}
		}
		.frame(width: 600)
		.padding()
		.onExitCommand {
			if text.isEmpty {
				customWindowPresentation?.dismiss()
			} else {
				text = ""
			}
		}
	}
}
