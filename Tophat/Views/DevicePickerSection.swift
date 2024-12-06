//
//  DevicePickerSection.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct DevicePickerSection: View {
	var title: LocalizedStringKey
	var devices: [Device]
	var isLoading: Bool

	var body: some View {
		HStack(alignment: .center) {
			Text(title)
				.sectionHeadingTextStyle()

			if isLoading {
				ProgressView()
					.progressViewStyle(.circular)
					.controlSize(.mini)
					.labelsHidden()
			}

			Spacer()
		}
		.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
		.padding(.top, Theme.Size.menuPaddingVertical)

		DevicePicker(devices: devices)
	}
}
