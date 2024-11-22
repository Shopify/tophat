//
//  LocationsTab.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-17.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct LocationsTab: View {
	var body: some View {
		Form {
			Section {
				JavaHomePicker()
			}

			Section {
				AndroidSDKPicker()
			}

			Section {
				ScreenCopyPicker()
			}
		}
		.formStyle(.grouped)
	}
}
