//
//  ParameterTextField.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
@_spi(TophatKitInternal) import TophatKit

struct ParameterTextField: View {
	var parameter: ArtifactProviderParameterSpecification

	@Binding var text: String

	var body: some View {
		TextField(text: $text, prompt: Text(parameter.prompt ?? parameter.title)) {
			HStack(alignment: .firstTextBaseline, spacing: 4) {
				Text(parameter.title)

				if let help = parameter.help {
					InfoButton(help: help)
				}
			}

			if let description = parameter.description {
				Text(description)
			}
		}
	}
}
