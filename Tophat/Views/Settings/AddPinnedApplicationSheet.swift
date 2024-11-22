//
//  AddPinnedApplicationSheet.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation
@_spi(TophatKitInternal) import TophatKit

struct AddPinnedApplicationSheet: View {
	@Environment(\.presentationMode) private var presentationMode
	@Environment(ExtensionHost.self) private var extensionHost
	@EnvironmentObject private var pinnedApplicationState: PinnedApplicationState

	private var editingApplicationID: String?

	@State private var name: String = ""
	@State private var platform: Platform = .iOS

	@State private var destinationPreset: DestinationPreset = .any

	@State private var artifactProviderID: String?
	@State private var simulatorArtifactProviderParameters: [String: String] = [:]
	@State private var deviceArtifactProviderParameters: [String: String] = [:]

	private var addOrUpdateText: String {
		editingApplicationID != nil ? "Update Quick Launch App" : "Add App to Quick Launch"
	}
	private var addOrUpdateButtonText: String {
		editingApplicationID != nil ? "Update App" : "Add App"
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Form {
				Section(addOrUpdateText) {
					TextField("Name", text: $name, prompt: Text("Name"))

					Picker("Platform", selection: $platform) {
						ForEach([Platform.iOS, Platform.android], id: \.self) { platform in
							Text(platform.description)
								.tag(platform)
						}
					}

					Picker("Source", selection: $artifactProviderID) {
						ForEach(artifactProviders) { artifactProvider in
							Text(artifactProvider.title)
								.tag(artifactProvider.id)
						}
					}
				}

				Section {
					Picker(selection: $destinationPreset) {
						ForEach(DestinationPreset.allCases, id: \.self) { type in
							Text(type.description)
						}
					} label: {
						Text("Destination")
						Text(destinationPreset.helpText)
					}
				}

				if let selectedArtifactProvider {
					if destinationPreset == .all || destinationPreset == .simulatorOnly || destinationPreset == .any {
						Section(destinationPreset == .all ? "Simulator Parameters" : "Parameters") {
							ForEach(selectedArtifactProvider.parameters, id: \.key) { parameter in
								ParameterTextField(
									parameter: parameter,
									text: simulatorArtifactProviderParameter(key: parameter.key)
								)
							}
						}
					}

					if destinationPreset == .all || destinationPreset == .deviceOnly {
						Section(destinationPreset == .all ? "Device Parameters" : "Parameters") {
							ForEach(selectedArtifactProvider.parameters, id: \.key) { parameter in
								ParameterTextField(
									parameter: parameter,
									text: deviceArtifactProviderParameter(key: parameter.key)
								)
							}
						}
					}
				}
			}
			.formStyle(.grouped)

			Divider()

			HStack {
				Spacer()

				Button("Cancel", action: performCancelAction)
					.keyboardShortcut(.cancelAction)

				Button(addOrUpdateButtonText, action: performDefaultAction)
					.keyboardShortcut(.defaultAction)
					.disabled(primaryActionDisabled)
			}
			.padding(20)
		}
		.frame(width: 500)
		.fixedSize()
		.scrollDisabled(true)
		.onAppear {
			if editingApplicationID == nil {
				artifactProviderID = artifactProviders.first?.id
			}
		}
		.onChange(of: artifactProviderID) { oldValue, newValue in
			simulatorArtifactProviderParameters.removeAll()
			deviceArtifactProviderParameters.removeAll()
		}
	}

	private var artifactProviders: [ArtifactProviderSpecification] {
		extensionHost.availableExtensions.flatMap(\.specification.artifactProviders)
	}

	private var selectedArtifactProvider: ArtifactProviderSpecification? {
		artifactProviders.first { $0.id == artifactProviderID }
	}

	private func simulatorArtifactProviderParameter(key: String) -> Binding<String> {
		.init(
			get: { simulatorArtifactProviderParameters[key, default: ""] },
			set: { simulatorArtifactProviderParameters[key] = $0 }
		)
	}

	private func deviceArtifactProviderParameter(key: String) -> Binding<String> {
		.init(
			get: { deviceArtifactProviderParameters[key, default: ""] },
			set: { deviceArtifactProviderParameters[key] = $0 }
		)
	}

	private var primaryActionDisabled: Bool {
		name.isEmpty || installRecipes.isEmpty
	}

	private func performCancelAction() {
		presentationMode.wrappedValue.dismiss()
	}

	private func performDefaultAction() {
		if let editingApplicationID,
		   let existingIndex = pinnedApplicationState.pinnedApplications.firstIndex(where: { $0.id == editingApplicationID }) {
			let existingItem = pinnedApplicationState.pinnedApplications[existingIndex]

			var newPinnedApplication = PinnedApplication(
				id: editingApplicationID,
				name: name,
				recipes: installRecipes
			)
			newPinnedApplication.icon = existingItem.icon
			pinnedApplicationState.pinnedApplications[existingIndex] = newPinnedApplication

		} else {
			let newPinnedApplication = PinnedApplication(
				name: name,
				recipes: installRecipes
			)
			pinnedApplicationState.pinnedApplications.append(newPinnedApplication)
		}

		presentationMode.wrappedValue.dismiss()
	}

	private var installRecipes: [InstallRecipe] {
		guard let selectedArtifactProvider else {
			return []
		}

		let simulatorArtifactProviderMetadata = ArtifactProviderMetadata(
			id: selectedArtifactProvider.id,
			parameters: simulatorArtifactProviderParameters
		)

		let artifactProviderMetadata = ArtifactProviderMetadata(
			id: selectedArtifactProvider.id,
			parameters: deviceArtifactProviderParameters
		)
		return switch destinationPreset {
			case .any:
				[
					.init(
						source: .artifactProvider(metadata: simulatorArtifactProviderMetadata),
						launchArguments: [],
						platformHint: platform
					)
				]
			case .all:
				[
					.init(
						source: .artifactProvider(metadata: simulatorArtifactProviderMetadata),
						launchArguments: [],
						platformHint: platform,
						destinationHint: .simulator
					),
					.init(
						source: .artifactProvider(metadata: artifactProviderMetadata),
						launchArguments: [],
						platformHint: platform,
						destinationHint: .device
					)
				]
			case .simulatorOnly:
				[
					.init(
						source: .artifactProvider(metadata: simulatorArtifactProviderMetadata),
						launchArguments: [],
						platformHint: platform,
						destinationHint: .simulator
					)
				]
			case .deviceOnly:
				[
					.init(
						source: .artifactProvider(metadata: artifactProviderMetadata),
						launchArguments: [],
						platformHint: platform,
						destinationHint: .device
					)
				]
		}
	}
}

private enum DestinationPreset {
	case any
	case all
	case simulatorOnly
	case deviceOnly
}

extension DestinationPreset {
	var helpText: LocalizedStringResource {
		switch self {
			case .any:
				return "This build can run on both simulators and devices."
			case .all:
				return "Simulators and devices require separate builds."
			case .simulatorOnly:
				return "This build can only run on simulators."
			case .deviceOnly:
				return "This build can only run on devices."
		}
	}
}

extension DestinationPreset: CaseIterable {}
extension DestinationPreset: CustomStringConvertible {
	var description: String {
		switch self {
			case .any:
				return "Any"
			case .all:
				return "All"
			case .simulatorOnly:
				return "Simulator"
			case .deviceOnly:
				return "Device"
		}
	}
}

extension AddPinnedApplicationSheet {
	init(applicationToEdit: PinnedApplication) {
		self.editingApplicationID = applicationToEdit.id
		_name = State(initialValue: applicationToEdit.name)
		_platform = State(initialValue: applicationToEdit.platform)

		let recipes = applicationToEdit.recipes

		_artifactProviderID = State(initialValue: recipes.first?.artifactProviderMetadata.id)

		if let virtualRecipe = recipes.first(where: { $0.destinationHint == .simulator }),
		   let physicalRecipe = recipes.first(where: { $0.destinationHint == .device }) {
			_destinationPreset = State(initialValue: .all)
			_simulatorArtifactProviderParameters = State(initialValue: virtualRecipe.artifactProviderMetadata.parameters)
			_deviceArtifactProviderParameters = State(initialValue: physicalRecipe.artifactProviderMetadata.parameters)
		} else if let physicalRecipe = recipes.first(where: { $0.destinationHint == .device }) {
			_destinationPreset = State(initialValue: .deviceOnly)
			_deviceArtifactProviderParameters = State(initialValue: physicalRecipe.artifactProviderMetadata.parameters)
		} else if let virtualRecipe = recipes.first(where: { $0.destinationHint == .simulator }) {
			_destinationPreset = State(initialValue: .simulatorOnly)
			_simulatorArtifactProviderParameters = State(initialValue: virtualRecipe.artifactProviderMetadata.parameters)
		} else if let firstRecipe = recipes.first {
			_destinationPreset = State(initialValue: .any)
			_simulatorArtifactProviderParameters = State(initialValue: firstRecipe.artifactProviderMetadata.parameters)
		}
	}
}

private extension InstallRecipe {
	var artifactProviderMetadata: ArtifactProviderMetadata {
		guard case .artifactProvider(let metadata) = source else {
			fatalError("Only build providers are supported in the graphical Quick Launch editor.")
		}

		return metadata
	}
}
