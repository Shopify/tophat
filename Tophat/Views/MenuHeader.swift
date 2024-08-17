//
//  MenuHeader.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-12.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct MenuHeader: View {
	var body: some View {
		HStack(alignment: .center) {
			if let displayName = Bundle.main.displayName {
				Text(displayName)
					.font(.body.bold())
					.foregroundColor(.primary)
			}

			Spacer()

			StatusView()
		}
	}
}
