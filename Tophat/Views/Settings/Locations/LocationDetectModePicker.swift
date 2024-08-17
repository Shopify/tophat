//
//  LocationDetectModePicker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

enum LocationDetectMode: Int {
	case automatic
	case custom
}

struct LocationDetectModePicker<Label: View>: View {
	@Binding var selection: LocationDetectMode
	@ViewBuilder var label: () -> Label

	var body: some View {
		Picker(selection: $selection) {
			Text("Automatic")
				.tag(LocationDetectMode.automatic)
			Text("Custom")
				.tag(LocationDetectMode.custom)
		} label: {
			label()
		}
	}
}
