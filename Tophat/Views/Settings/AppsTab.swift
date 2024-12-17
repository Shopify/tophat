//
//  AppsTab.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import SwiftData

struct AppsTab: View {
	@Environment(\.modelContext) private var modelContext

	@AppStorage("ShowQuickLaunch") private var showQuickLaunch = true

	@State private var selectedEntry: QuickLaunchEntry?
	@State private var editingEntry: QuickLaunchEntry?
	@State private var isAddingNewEntry = false

	@Query(sort: \QuickLaunchEntry.order)
	var entries: [QuickLaunchEntry]

	var body: some View {
		Form {
			Section {
				HStack(alignment: .top, spacing: 12) {
					SymbolChip(systemName: "square.grid.2x2.fill", color: .pink)
						.imageScale(.large)

					Toggle(isOn: $showQuickLaunch) {
						Text("Quick Launch")
						Text("The apps below are displayed in the Quick Launch panel so that you can launch them with one click.")
					}
					.controlSize(.large)
				}
			}

			Section {
				List(selection: $selectedEntry) {
					ForEach(entries) { entry in
						QuickLaunchEntryRow(entry: entry)
							.tag(entry)
							.listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
					}
					.onMove { indexSet, offset in
						var mutableEntries = entries

						mutableEntries.move(fromOffsets: indexSet, toOffset: offset)

						for (index, entry) in mutableEntries.enumerated() {
							entry.order = index
						}

						try? self.modelContext.save()
					}
					.onDelete { indexSet in
						for index in indexSet {
							let entry = entries[index]
							modelContext.delete(entry)
							try? modelContext.save()
						}
					}
				}
				.listGradientButtons {
					GradientButton(style: .plus) {
						isAddingNewEntry = true
					}
				} minusButton: {
					GradientButton(style: .minus) {
						if let selectedEntry {
							modelContext.delete(selectedEntry)
							try? modelContext.save()
							self.selectedEntry = nil
						}
					}
					.disabled(selectedEntry == nil)
				}
				.contextMenu(forSelectionType: QuickLaunchEntry.self) { selectionSet in
					Button("Edit…") {
						editingEntry = entries.first { $0 == selectionSet.first }
					}
				} primaryAction: { selectionSet in
					editingEntry = entries.first { $0 == selectionSet.first }
				}
			}
			.disabled(!showQuickLaunch)
		}
		.formStyle(.grouped)
		.onTapGesture(count: 1) {
			selectedEntry = nil
		}
		.sheet(item: $editingEntry) { entry in
			QuickLaunchEntrySheet(entry: entry)
		}
		.sheet(isPresented: $isAddingNewEntry) {
			QuickLaunchEntrySheet()
		}
	}
}
