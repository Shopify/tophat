//
//  CustomWindowPresentation.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

protocol CustomWindowPresentation {
	@MainActor func dismiss()
}

extension EnvironmentValues {
	@Entry var customWindowPresentation: CustomWindowPresentation? = nil
}
