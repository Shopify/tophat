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
	@State private var recipes: [QuickLaunchEntryRecipe] = []

	@State private var selectedRecipe: QuickLaunchEntryRecipe?
	@State private var editingRecipe: QuickLaunchEntryRecipe?

	@State private var isAddingNewRecipe = false

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Form {
				Section {
					TextField("Name", text: $name, prompt: Text("Name"))
				}

				Section {
					List(selection: $selectedRecipe) {
						ForEach(recipes) { recipe in
							if let artifactProvider = artifactProvider(id: recipe.artifactProviderID) {
								VStack(alignment: .leading, spacing: 3) {
									Text(artifactProvider.title)
									HStack {
										BadgedText(text: Text(String(describing: recipe.platformHint)))

										if let destinationHint = recipe.destinationHint {
											BadgedText(text: Text(String(describing: destinationHint)))
										}
									}
								}
								.listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
								.tag(recipe)
							}
						}
						.onMove { indexSet, offset in
							recipes.move(fromOffsets: indexSet, toOffset: offset)
						}
						.onDelete { indexSet in
							recipes.remove(atOffsets: indexSet)
						}
					}
					.listGradientButtons {
						GradientButton(style: .plus) {
							isAddingNewRecipe = true
						}
					} minusButton: {
						GradientButton(style: .minus) {
							if let selectedRecipeID = selectedRecipe?.id {
								recipes.removeAll { $0.id == selectedRecipeID }
							}
						}
						.disabled(selectedRecipe == nil)
					}
					.contextMenu(forSelectionType: QuickLaunchEntryRecipe.self) { selectionSet in
						Button("Edit…") {
							editingRecipe = recipes.first { $0 == selectionSet.first }
						}
					} primaryAction: { selectionSet in
						editingRecipe = recipes.first { $0 == selectionSet.first }
					}
				} header: {
					Text("Recipes")
					Text("Create one or more recipes so that Tophat can install this application to each of your selected devices.")
				}
			}
			.formStyle(.grouped)

			Divider()

			FormFooterView(
				defaultActionTitleKey: entry == nil ? "Add" : "Save",
				defaultActionDisabled: name.isEmpty || recipes.isEmpty
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
				self.recipes = entry.recipes
			}
		}
		.onTapGesture(count: 1) {
			selectedRecipe = nil
		}
		.sheet(isPresented: $isAddingNewRecipe) {
			QuickLaunchEntryRecipeSheet(recipes: $recipes)
		}
		.sheet(item: $editingRecipe) { recipe in
			QuickLaunchEntryRecipeSheet(recipes: $recipes, recipe: recipe)
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
			entry.recipes = recipes
		} else {
			var fetchDescriptor = FetchDescriptor<QuickLaunchEntry>(
				sortBy: [SortDescriptor(\.order, order: .reverse)]
			)
			fetchDescriptor.fetchLimit = 1

			let existingEntries = try? modelContext.fetch(fetchDescriptor)
			let lastOrder = existingEntries?.first?.order ?? 0

			let newEntry = QuickLaunchEntry(name: name, recipes: recipes, order: lastOrder + 1)
			modelContext.insert(newEntry)
		}
	}
}
