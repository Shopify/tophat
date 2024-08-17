//
//  AppsTab.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct AppsTab: View {
	@AppStorage("ShowQuickLaunch") private var showQuickLaunch = true
	@EnvironmentObject private var pinnedApplicationState: PinnedApplicationState
	@State private var selection: String?
	@State private var editingApplication: PinnedApplication? = nil
	@State private var addPinnedApplicationSheetVisible = false

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
				List(selection: $selection) {
					ForEach(pinnedApplicationState.pinnedApplications) { application in
						PinnedApplicationRow(application: application)
							.listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
					}
					.onMove(perform: move)
				}
				.listGradientButtons {
					GradientButton(style: .plus) {
						addPinnedApplicationSheetVisible = true
					}

				} minusButton: {
					GradientButton(style: .minus) {
						pinnedApplicationState.pinnedApplications.removeAll { $0.id == selection }
						selection = nil
					}
					.disabled(selection == nil)
				}
				.contextMenu(forSelectionType: String.self) { selectionSet in
					Button("Edit…") {
						editingApplication = pinnedApplicationState.pinnedApplications.first { $0.id == selectionSet.first }
					}
				} primaryAction: { selectionSet in
					editingApplication = pinnedApplicationState.pinnedApplications.first { $0.id == selectionSet.first }
				}

			}
			.disabled(!showQuickLaunch)
		}
		.formStyle(.grouped)
		.onTapGesture(count: 1) {
			selection = nil
		}
		.sheet(isPresented: $addPinnedApplicationSheetVisible) {
			AddPinnedApplicationSheet()
		}
		.sheet(item: $editingApplication) { app in
			AddPinnedApplicationSheet(applicationToEdit: app)
		}
	}

	private func move(from source: IndexSet, to destination: Int) {
		pinnedApplicationState.pinnedApplications.move(fromOffsets: source, toOffset: destination)
	}
}
