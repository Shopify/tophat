//
//  AddPinnedApplicationSheet.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct AddPinnedApplicationSheet: View {
	/// If editing an existing PinnedApplication, we store the ID. If adding a new one, this is nil. 
	private let editingApplicationID: String?
	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject private var pinnedApplicationState: PinnedApplicationState

	@State private var name: String = ""
	@State private var platform: Platform = .iOS
	@State private var artifactSource: ArtifactSource = .direct
	@State private var url: String = ""
	@State private var virtualURL: String = ""
	@State private var physicalURL: String = ""
	@State private var artifactProviderURL: String = ""

	@State private var urlSetType: URLSetType = .universal

	private var addOrUpdateText: String {
		editingApplicationID != nil ? "Update Quick Launch App" : "Add App to Quick Launch"
	}
	private var addOrUpdateButtonText: String {
		editingApplicationID != nil ? "Update App" : "Add App"
	}

	init() {
		self.editingApplicationID = nil
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

					Picker("Source", selection: $artifactSource) {
						ForEach(ArtifactSource.allCases, id: \.self) { source in
							Text(String(describing: source))
								.tag(source)
						}
					}
				}

				switch artifactSource {
					case .direct:
						Section {
							Picker(selection: $urlSetType) {
								ForEach(URLSetType.allCases, id: \.self) { type in
									Text(type.description)
								}
							} label: {
								Text("Build Type")
								Text(buildTypeDescription)
							}
						}

						Section {
							if urlSetType == .multiTarget {
								TextField("Virtual", text: $virtualURL, prompt: Text("URL"))
								TextField("Physical", text: $physicalURL, prompt: Text("URL"))
							} else {
								TextField("URL", text: $url, prompt: Text("URL"))
							}

							Text("For builds that are updated regularly, use a constant URL that always points to the latest version.")
								.font(.subheadline)
								.foregroundColor(.secondary)
								.fixedSize(horizontal: false, vertical: true)
						}
					case .api:
						Section {
							TextField("URL", text: $artifactProviderURL, prompt: Text("URL"))

							Text("Use a constant URL to an endpoint that conforms to the Tophat API specification. Tophat will authenticate automatically using the token found in `~/.tophatrc`.")
								.font(.subheadline)
								.foregroundColor(.secondary)
								.fixedSize(horizontal: false, vertical: true)
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
	}

	private var buildTypeDescription: String {
		switch urlSetType {
			case .universal:
				return "This build can run on both virtual and physical devices."
			case .multiTarget:
				return "Virtual devices and physical devices require separate builds located at two separate URLs."
			case .virtualOnly:
				return "This build can only run on virtual devices."
			case .physicalOnly:
				return "This build can only run on physical devices."
		}
	}

	private var primaryActionDisabled: Bool {
		let urlsValid: Bool = {
			switch artifactSource {
				case .direct:
					switch urlSetType {
						case .universal, .virtualOnly, .physicalOnly:
							return url.isValidURL
						case .multiTarget:
							return physicalURL.isValidURL && virtualURL.isValidURL
					}
				case .api:
					return artifactProviderURL.isValidURL
			}
		}()

		return name.isEmpty || !urlsValid
	}

	private func performCancelAction() {
		presentationMode.wrappedValue.dismiss()
	}

	private func performDefaultAction() {
		if let editingApplicationID = editingApplicationID,
		   let existingIndex = pinnedApplicationState.pinnedApplications.firstIndex(where: { $0.id == editingApplicationID }) {
			let existingItem = pinnedApplicationState.pinnedApplications[existingIndex]

			var newPinnedApplication = PinnedApplication(
				id: editingApplicationID,
				name: name,
				platform: platform,
				artifacts: artifacts,
				artifactProviderURL: parsedArtifactProviderURL
			)
			newPinnedApplication.icon = existingItem.icon
			pinnedApplicationState.pinnedApplications[existingIndex] = newPinnedApplication

		} else {
			let newPinnedApplication = PinnedApplication(
				name: name,
				platform: platform,
				artifacts: artifacts,
				artifactProviderURL: parsedArtifactProviderURL
			)
			pinnedApplicationState.pinnedApplications.append(newPinnedApplication)
		}

		presentationMode.wrappedValue.dismiss()
	}

	private var artifacts: [Artifact] {
		guard artifactSource == .direct else {
			return []
		}

		// URLs are being force-unwrapped as performDefaultAction can only be called if its button is enabled.
		// We check the validity before enabling the button.
		switch urlSetType {
			case .universal:
				return [Artifact(url: URL(string: url)!, targets: [.virtual, .physical])]
			case .multiTarget:
				return [
					Artifact(url: URL(string: virtualURL)!, targets: [.virtual]),
					Artifact(url: URL(string: physicalURL)!, targets: [.physical])
				]
			case .virtualOnly:
				return [Artifact(url: URL(string: url)!, targets: [.virtual])]
			case .physicalOnly:
				return [Artifact(url: URL(string: url)!, targets: [.physical])]
		}
	}

	private var parsedArtifactProviderURL: URL? {
		guard artifactSource == .api else {
			return nil
		}

		return URL(string: artifactProviderURL)
	}
}

private enum ArtifactSource {
	case direct
	case api
}

extension ArtifactSource: CaseIterable {}
extension ArtifactSource: CustomStringConvertible {
	var description: String {
		switch self {
			case .direct:
				return "Direct Link"
			case .api:
				return "Tophat API"
		}
	}
}

private enum URLSetType {
	case universal
	case multiTarget
	case virtualOnly
	case physicalOnly
}

extension URLSetType: CaseIterable {}
extension URLSetType: CustomStringConvertible {
	var description: String {
		switch self {
			case .universal:
				return "Universal"
			case .multiTarget:
				return "Multi-Target"
			case .virtualOnly:
				return "Virtual Only"
			case .physicalOnly:
				return "Physical Only"
		}
	}
}

extension AddPinnedApplicationSheet {
	init(applicationToEdit: PinnedApplication) {
		self.editingApplicationID = applicationToEdit.id
		_name = State(initialValue: applicationToEdit.name)
		_platform = State(initialValue: applicationToEdit.platform)

		let artifactSet = ArtifactSet(artifacts: applicationToEdit.artifacts)
		let physicalArtifact = artifactSet.artifacts(targeting: .physical).first
		let virtualArtifact = artifactSet.artifacts(targeting: .virtual).first

		if let virtualArtifact = virtualArtifact,
		   let physicalArtifact = physicalArtifact {
			let isUniversal = physicalArtifact.url == virtualArtifact.url

			_urlSetType = State(initialValue: isUniversal ? .universal : .multiTarget)

			if isUniversal {
				// They're identical, so just use any one of them.
				_url = State(from: physicalArtifact)
			} else {
				_virtualURL = State(from: virtualArtifact)
				_physicalURL = State(from: physicalArtifact)
			}
		} else if let physicalArtifact = physicalArtifact {
			_urlSetType = State(initialValue: .physicalOnly)
			_url = State(from: physicalArtifact)
		} else if let virtualArtifact = virtualArtifact {
			_urlSetType = State(initialValue: .virtualOnly)
			_url = State(from: virtualArtifact)
		} else if let artifactProviderURL = applicationToEdit.artifactProviderURL {
			_artifactSource = State(initialValue: .api)
			_artifactProviderURL = State(initialValue: artifactProviderURL.absoluteString)
		}
	}

}

private extension State where Value == String {
	init(from artifact: Artifact) {
		self.init(initialValue: artifact.url.absoluteString)
	}
}
