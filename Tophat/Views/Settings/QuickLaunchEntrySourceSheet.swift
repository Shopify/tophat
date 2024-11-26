//
//  QuickLaunchEntrySourceSheet.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-25.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation
@_spi(TophatKitInternal) import TophatKit

struct QuickLaunchEntrySourceSheet: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Environment(ExtensionHost.self) private var extensionHost

	@Binding var sources: [QuickLaunchEntrySource]
	var source: QuickLaunchEntrySource?

	@State private var artifactProviderID: String?
	@State private var artifactProviderParameters: [String: String] = [:]
	@State private var launchArguments: [String] = []
	@State private var platform: Platform = .iOS
	@State private var destination: DeviceType?

	@State private var selectedLaunchArgumentIndex: Int?

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Form {
				Section {
					Picker("Provider", selection: $artifactProviderID) {
						ForEach(artifactProviders) { artifactProvider in
							Text(artifactProvider.title)
								.tag(artifactProvider.id)
						}
					}
				}

				Section {
					Picker("Platform", selection: $platform) {
						ForEach([Platform.iOS, Platform.android], id: \.self) { platform in
							Text(String(describing: platform))
								.tag(platform)
						}
					}

					Picker(selection: $destination) {
						Text("Any")
							.tag(Optional<DeviceType>.none)

						ForEach(Array(DeviceType.allCases), id: \.self) { deviceType in
							Text(String(describing: deviceType))
								.tag(Optional(deviceType))
						}
					} label: {
						Text("Destination")
						Text(destinationHelpText)
					}
				}

				if let selectedArtifactProvider {
					Section("Parameters") {
						ForEach(selectedArtifactProvider.parameters, id: \.key) { parameter in
							ParameterTextField(
								parameter: parameter,
								text: parameterBinding(key: parameter.key)
							)
						}
					}
				}

				Section("Launch Arguments") {
					List(selection: $selectedLaunchArgumentIndex) {
						ForEach(Array($launchArguments.enumerated()), id: \.0) { (index, $launchArgument) in
							TextField("Blank Argument", text: $launchArgument)
								.tag(launchArgument)
						}
						.onMove { indexSet, offset in
							launchArguments.move(fromOffsets: indexSet, toOffset: offset)
						}
						.onDelete { indexSet in
							launchArguments.remove(atOffsets: indexSet)
						}
					}
					.listGradientButtons {
						GradientButton(style: .plus) {
							launchArguments.append("")
						}
					} minusButton: {
						GradientButton(style: .minus) {
							if let selectedLaunchArgumentIndex {
								launchArguments.remove(at: selectedLaunchArgumentIndex)
							}
							selectedLaunchArgumentIndex = nil
						}
						.disabled(selectedLaunchArgumentIndex == nil)
					}
				}
			}
			.formStyle(.grouped)

			Divider()

			FormFooterView(
				defaultActionTitleKey: source == nil ? "Add" : "Save",
				defaultActionDisabled: defaultActionDisabled
			) {
				performSave()
				dismiss()
			} cancelAction: {
				dismiss()
			}
		}
		.frame(width: 500)
		.fixedSize()
		.onAppear {
			if let source {
				self.artifactProviderID = source.artifactProviderID
				self.artifactProviderParameters = source.artifactProviderParameters
				self.launchArguments = source.launchArguments
				self.platform = source.platformHint
				self.destination = source.destinationHint
			} else if artifactProviderID == nil {
				artifactProviderID = artifactProviders.first?.id
			}
		}
	}

	private var artifactProviders: [ArtifactProviderSpecification] {
		extensionHost.availableExtensions.flatMap(\.specification.artifactProviders)
	}

	private var selectedArtifactProvider: ArtifactProviderSpecification? {
		artifactProviders.first { $0.id == artifactProviderID }
	}

	private var destinationHelpText: LocalizedStringKey {
		switch destination {
			case .simulator:
				"This build can only run on simulators."
			case .device:
				"This build can only run on devices."
			case nil:
				"This build can run on both simulators and devices."
		}
	}

	private var defaultActionDisabled: Bool {
		guard let selectedArtifactProvider else {
			return true
		}

		for parameter in selectedArtifactProvider.parameters {
			if !parameter.isOptional {
				return artifactProviderParameters[parameter.key, default: ""].isEmpty
			}
		}

		return false
	}

	private func parameterBinding(key: String) -> Binding<String> {
		Binding(
			get: { artifactProviderParameters[key, default: ""] },
			set: { artifactProviderParameters[key] = $0 }
		)
	}

	private func performSave() {
		guard let artifactProviderID else {
			return
		}

		if let source {
			source.artifactProviderID = artifactProviderID
			source.artifactProviderParameters = self.artifactProviderParameters
			source.launchArguments = self.launchArguments
			source.platformHint = self.platform
			source.destinationHint = self.destination

		} else {
			let newSource = QuickLaunchEntrySource(
				artifactProviderID: artifactProviderID,
				artifactProviderParameters: self.artifactProviderParameters,
				launchArguments: self.launchArguments,
				platformHint: self.platform,
				destinationHint: self.destination
			)

			sources.append(newSource)
		}
	}
}
