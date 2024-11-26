//
//  QuickLaunchEntrySheet.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import SwiftData
import TophatFoundation
@_spi(TophatKitInternal) import TophatKit

struct QuickLaunchEntrySheet: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Environment(ExtensionHost.self) private var extensionHost

	var entry: QuickLaunchEntry?

	@State private var name: String = ""
	@State private var sources: [QuickLaunchEntrySource] = []

	@State private var selectedSource: QuickLaunchEntrySource?
	@State private var editingSource: QuickLaunchEntrySource?

	@State private var isAddingNewSource = false

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Form {
				Section {
					TextField("Name", text: $name, prompt: Text("Name"))
				}

				Section {
					List(selection: $selectedSource) {
						ForEach(sources) { source in
							if let artifactProvider = artifactProvider(id: source.artifactProviderID) {
								VStack(alignment: .leading, spacing: 3) {
									Text(artifactProvider.title)
									HStack {
										BadgedText(text: Text(String(describing: source.platformHint)))

										if let destinationHint = source.destinationHint {
											BadgedText(text: Text(String(describing: destinationHint)))
										}
									}
								}
								.listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
								.tag(source)
							}
						}
						.onMove { indexSet, offset in
							sources.move(fromOffsets: indexSet, toOffset: offset)
						}
						.onDelete { indexSet in
							sources.remove(atOffsets: indexSet)
						}
					}
					.listGradientButtons {
						GradientButton(style: .plus) {
							isAddingNewSource = true
						}
					} minusButton: {
						GradientButton(style: .minus) {
							if let selectedSourceID = selectedSource?.id {
								sources.removeAll { $0.id == selectedSourceID }
							}
						}
						.disabled(selectedSource == nil)
					}
					.contextMenu(forSelectionType: QuickLaunchEntrySource.self) { selectionSet in
						Button("Edit…") {
							editingSource = sources.first { $0 == selectionSet.first }
						}
					} primaryAction: { selectionSet in
						editingSource = sources.first { $0 == selectionSet.first }
					}
				} header: {
					Text("Sources")
					Text("Create one or more sources so that Tophat can install this application to each of your selected devices.")
				}
			}
			.formStyle(.grouped)

			Divider()

			FormFooterView(
				defaultActionTitleKey: entry == nil ? "Add" : "Save",
				defaultActionDisabled: name.isEmpty || sources.isEmpty
			) {
				performSave()
				dismiss()
			} cancelAction: {
				dismiss()
			}
		}
		.frame(width: 550)
		.fixedSize()
		.onAppear {
			if let entry {
				self.name = entry.name
				self.sources = entry.sources
			}
		}
		.onTapGesture(count: 1) {
			selectedSource = nil
		}
		.sheet(isPresented: $isAddingNewSource) {
			QuickLaunchEntrySourceSheet(sources: $sources)
		}
		.sheet(item: $editingSource) { source in
			QuickLaunchEntrySourceSheet(sources: $sources, source: source)
		}
	}

	private var artifactProviders: [ArtifactProviderSpecification] {
		extensionHost.availableExtensions.flatMap(\.specification.artifactProviders)
	}

	private func artifactProvider(id: ArtifactProviderSpecification.ID) -> ArtifactProviderSpecification? {
		artifactProviders.first { $0.id == id }
	}

	private func performSave() {
		if let entry {
			entry.name = name
			entry.sources = sources
		} else {
			var fetchDescriptor = FetchDescriptor<QuickLaunchEntry>(
				sortBy: [SortDescriptor(\.order, order: .reverse)]
			)
			fetchDescriptor.fetchLimit = 1

			let existingEntries = try? modelContext.fetch(fetchDescriptor)
			let lastOrder = existingEntries?.first?.order ?? 0

			let newEntry = QuickLaunchEntry(name: name, sources: sources, order: lastOrder + 1)
			modelContext.insert(newEntry)
		}
	}
}
