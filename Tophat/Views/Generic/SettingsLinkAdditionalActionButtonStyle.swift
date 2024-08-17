//
//  SettingsLinkAdditionalActionButtonStyle.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-09-15.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct SettingsLinkAdditionalActionButtonStyle: PrimitiveButtonStyle {
	let perform: () -> Void

	func makeBody(configuration: Configuration) -> some View {
		Button {
			perform()
			configuration.trigger()
		} label: {
			configuration.label
		}
	}
}
