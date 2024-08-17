//
//  AndroidSDKPicker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct AndroidSDKPicker: View {
	@EnvironmentObject private var utilityPathPreferences: UtilityPathPreferences

	var body: some View {
		LocationPicker(
			preferredValue: $utilityPathPreferences.preferredAndroidSDKPath,
			resolvedValue: utilityPathPreferences.resolvedAndroidSDKLocation?.path(percentEncoded: false)
		) {
			Text("Android SDK")
			Text("The folder in which the Android SDK is located.")
		} icon: {
			SymbolChip("android.fill", color: .green)
		}
	}
}
