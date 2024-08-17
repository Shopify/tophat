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
	@AppStorage("LaunchFromURLIsAPI") private var isAPI = false

	var body: some View {
		VStack(spacing: 12) {
			TextField("URL", text: $text, prompt: Text(isAPI ? "Endpoint URL" : "Artifact URL"))
				.textFieldStyle(.plain)
				.font(.title)
				.foregroundColor(colorScheme == .dark ? .white : .primary)

			HStack(alignment: .firstTextBaseline, spacing: 14) {
				Spacer()

				Toggle("API", isOn: $isAPI)
					.toggleStyle(.checkbox)

				HStack(alignment: .firstTextBaseline) {
					Button("Cancel") {
						customWindowPresentation?.dismiss()
						text = ""
					}

					Button("Launch") {
						if let url = URL(string: text) {
							text = ""

							Task.detached(priority: .userInitiated) {
								if isAPI {
									await launchApp?(artifactProviderURL: url)
								} else {
									await launchApp?(artifactURL: url)
								}
							}
						}

						customWindowPresentation?.dismiss()
					}
					.keyboardShortcut(.defaultAction)
					.disabled(!text.isValidURL)
				}
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
