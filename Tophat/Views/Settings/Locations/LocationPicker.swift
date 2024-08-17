//
//  LocationPicker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct LocationPicker<Label: View, Icon: View>: View {
	@State private var mode: LocationDetectMode
	@Binding private var preferredValue: String?
	private let resolvedValue: String?
	private let label: () -> Label
	private let icon: () -> Icon

	init(
		preferredValue: Binding<String?>,
		resolvedValue: String?,
		@ViewBuilder label: @escaping () -> Label,
		@ViewBuilder icon: @escaping () -> Icon
	) {
		self._mode = State(initialValue: preferredValue.wrappedValue == nil ? .automatic : .custom)
		self._preferredValue = preferredValue
		self.resolvedValue = resolvedValue
		self.label = label
		self.icon = icon
	}

	var body: some View {
		HStack(alignment: .top, spacing: 12) {
			icon()

			LocationDetectModePicker(selection: $mode) {
				label()
			}
		}
		.onChange(of: mode) { newValue in
			if mode == .automatic {
				preferredValue = nil
			}
		}

		TextField("Location", text: text, prompt: prompt)
			.disabled(mode == .automatic)
	}

	private var text: Binding<String> {
		Binding {
			preferredValue ?? resolvedValue ?? ""

		} set: { newValue in
			if mode == .custom {
				preferredValue = newValue
			}
		}
	}

	private var prompt: Text? {
		guard text.wrappedValue.isEmpty else {
			return nil
		}

		switch mode {
			case .automatic:
				return Text("Not Found")
			case .custom:
				return Text("Custom Location")
		}
	}
}
