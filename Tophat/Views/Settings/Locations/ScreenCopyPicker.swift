//
//  ScreenCopyPicker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct ScreenCopyPicker: View {
	@EnvironmentObject private var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		LocationPicker(
			preferredValue: $utilityPathPreferences.preferredScrcpyPath,
			resolvedValue: utilityPathPreferences.resolvedScrcpyLocation?.path(percentEncoded: false)
		) {
			Text("scrcpy")
			Text("The location of the scrcpy tool.")
		} icon: {
			SymbolChip(systemName: "display", color: .purple)
		}
	}
}
