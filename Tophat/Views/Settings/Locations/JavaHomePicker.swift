//
//  JavaHomePicker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct JavaHomePicker: View {
	@EnvironmentObject private var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		LocationPicker(
			preferredValue: $utilityPathPreferences.preferredJavaHomePath,
			resolvedValue: utilityPathPreferences.resolvedJavaHomeLocation?.path(percentEncoded: false)
		) {
			Text("Java Home")
			Text("The folder in which Java is located.")
		} icon: {
			SymbolChip(systemName: "cup.and.saucer.fill", color: .blue)
		}
	}
}
