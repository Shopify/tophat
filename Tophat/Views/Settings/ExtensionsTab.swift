//
//  ExtensionsTab.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-09-24.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
import ExtensionFoundation
import ExtensionKit
@_spi(TophatKitInternal) import TophatKit

struct ExtensionsTab: View {
	@Environment(ExtensionHost.self) private var extensionHost

	@State private var selectedExtension: TophatExtension?

	var body: some View {
		Form {
			Section {
				ForEach(extensionHost.availableExtensions) { availableExtension in
					LabeledContent {
						Button("Info", systemImage: "info.circle") {
							selectedExtension = availableExtension
						}
						.labelStyle(.iconOnly)
						.buttonStyle(.borderless)
						.font(.title2)
						.fontWeight(.light)
						.disabled(!availableExtension.specification.isConfigurable)
					} label: {
						Label {
							Text(availableExtension.specification.title)
							Text(availableExtension.specification.description ?? "")
						} icon: {
							SymbolChip(systemName: "puzzlepiece.extension.fill", color: .gray)
								.imageScale(.medium)
								.padding(.top, 3)
						}
					}
					.padding([.leading, .vertical], 4)
				}
			} header: {
				Text("Extensions")
				Text("Extensions are used to add extra functionality to Tophat. Some extensions have adjustable settings that can be revealed using the \(Image(systemName: "info.circle")) button.")
			}

			Section {
				Text("Tophat extensions can be enabled or disabled in [System Settings](x-apple.systempreferences:com.apple.preference).")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
		.formStyle(.grouped)
		.sheet(item: $selectedExtension) { selectedExtension in
			VStack(spacing: 0) {
				ExtensionSettingsHostingView(identity: selectedExtension.identity)
					.frame(minHeight: 300)

				Divider()

				HStack {
					Spacer()
					Button("Done") {
						self.selectedExtension = nil
					}
				}
				.padding(20)
			}
		}
	}
}

private struct ExtensionSettingsHostingView: NSViewControllerRepresentable {
	var identity: AppExtensionIdentity

	func makeNSViewController(context: Context) -> EXHostViewController {
		let hostViewController = EXHostViewController()
		hostViewController.configuration = EXHostViewController.Configuration(
			appExtension: identity,
			sceneID: "TophatExtensionSettings"
		)

		return hostViewController
	}

	func updateNSViewController(_ nsViewController: EXHostViewController, context: Context) {
		nsViewController.configuration = EXHostViewController.Configuration(
			appExtension: identity,
			sceneID: "TophatExtensionSettings"
		)
	}
}
