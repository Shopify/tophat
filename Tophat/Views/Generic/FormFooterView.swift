//
//  FormFooterView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-25.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI

struct FormFooterView: View {
	var defaultActionTitleKey: LocalizedStringKey
	var defaultActionDisabled: Bool
	var defaultAction: () -> Void
	var cancelAction: () -> Void

	var body: some View {
		HStack {
			Spacer()

			Button("Cancel", action: cancelAction)
				.keyboardShortcut(.cancelAction)

			Button(defaultActionTitleKey, action: defaultAction)
				.keyboardShortcut(.defaultAction)
				.disabled(defaultActionDisabled)
		}
		.padding(20)
	}
}
