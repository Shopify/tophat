//
//  QuickLaunchEntryRecipeSheet.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-25.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation
@_spi(TophatKitInternal) import TophatKit

struct QuickLaunchEntryRecipeSheet: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Environment(ExtensionHost.self) private var extensionHost

	@Binding var recipes: [QuickLaunchEntryRecipe]
	var recipe: QuickLaunchEntryRecipe?

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
						ForEach(Platform.allCases.filter { $0 != .unknown }, id: \.self) { platform in
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
				defaultActionTitleKey: recipe == nil ? "Add" : "Save",
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
			if let recipe {
				self.artifactProviderID = recipe.artifactProviderID
				self.artifactProviderParameters = recipe.artifactProviderParameters
				self.launchArguments = recipe.launchArguments
				self.platform = recipe.platformHint
				self.destination = recipe.destinationHint
			} else if artifactProviderID == nil {
				artifactProviderID = artifactProviders.first?.id
			}
		}
		.onChange(of: artifactProviderID, initial: false) { oldValue, newValue in
			if oldValue != nil, newValue != nil, newValue != oldValue {
				artifactProviderParameters.removeAll()
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

		if let recipe {
			recipe.artifactProviderID = artifactProviderID
			recipe.artifactProviderParameters = self.artifactProviderParameters
			recipe.launchArguments = self.launchArguments
			recipe.platformHint = self.platform
			recipe.destinationHint = self.destination

		} else {
			let newRecipe = QuickLaunchEntryRecipe(
				artifactProviderID: artifactProviderID,
				artifactProviderParameters: self.artifactProviderParameters,
				launchArguments: self.launchArguments,
				platformHint: self.platform,
				destinationHint: self.destination
			)

			recipes.append(newRecipe)
		}
	}
}
