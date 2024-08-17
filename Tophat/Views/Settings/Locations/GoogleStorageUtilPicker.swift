//
//  GoogleStorageUtilPicker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-24.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct GoogleStorageUtilPicker: View {
	@EnvironmentObject private var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		LocationPicker(
			preferredValue: $utilityPathPreferences.preferredGSUtilPath,
			resolvedValue: utilityPathPreferences.resolvedGSUtilLocation?.path(percentEncoded: false)
		) {
			Text("gsutil")
			Text("The location of the Google Cloud Storage utility.")
		} icon: {
			SymbolChip(systemName: "externaldrive.fill", color: .indigo)
		}
	}
}
