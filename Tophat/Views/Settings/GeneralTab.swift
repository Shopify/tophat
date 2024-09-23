//
//  GeneralTab.swift
//  Tophat
//
//  Created by Harley Cooper on 2023-01-11.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct GeneralTab: View {
	@Environment(UpdateController.self) private var updateController
	@EnvironmentObject private var launchAtLoginController: LaunchAtLoginController
	@EnvironmentObject private var symbolicLinkManager: TophatCtlSymbolicLinkManager

	var body: some View {
		@Bindable var updateController = updateController

		Form {
			Section {
				Toggle(isOn: $launchAtLoginController.isEnabled) {
					Text("Open at Login")
					Text("When enabled, Tophat will open automatically when you log in.")
				}
				.controlSize(.large)
			}

			Section {
				HStack {
					Text("Command Line Helper")

					Spacer()

					Text(symbolicLinkInstallationStatusText)
						.foregroundColor(.secondary)

					Button {
						Task {
							await toggleSymbolicLinkInstallation()
						}
					} label: {
						Text(symbolicLinkButtonText)
					}
				}

				Text("When installed, you can use the `tophatctl` command to interact with and configure Tophat from the command line.")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}

			Section {
				Toggle(isOn: $updateController.isAutomaticUpdateCheckEnabled) {
					Text("Automatically Check for Updates")
					Text("When enabled, Tophat will periodically check for new updates.")
				}
				.controlSize(.large)

				Toggle(isOn: $updateController.isAutomaticUpdateDownloadEnabled) {
					Text("Automatically Download Updates")
				}
				.controlSize(.mini)
				.disabled(!updateController.isAutomaticUpdateCheckEnabled)

				HStack(spacing: 12) {
					Spacer()

					if updateController.isCheckingForUpdates {
						ProgressView()
							.progressViewStyle(.circular)
							.controlSize(.small)
					}

					Button("Check for Updates…") {
						updateController.checkForUpdates()
					}
					.disabled(!updateController.canCheckForUpdates || updateController.isCheckingForUpdates)
				}
			}
		}
		.formStyle(.grouped)
	}

	private var symbolicLinkButtonText: String {
		symbolicLinkManager.isInstalled ? "Uninstall…" : "Install…"
	}

	private var symbolicLinkInstallationStatusText: String {
		symbolicLinkManager.isInstalled ? "Installed" : "Not Installed"
	}

	private func toggleSymbolicLinkInstallation() async {
		if symbolicLinkManager.isInstalled {
			await symbolicLinkManager.uninstall()
		} else {
			await symbolicLinkManager.install()
		}
	}
}
