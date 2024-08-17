//
//  CustomWindowPresentation.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

protocol CustomWindowPresentation {
	func dismiss()
}

private struct CustomWindowPresentationKey: EnvironmentKey {
	static let defaultValue: CustomWindowPresentation? = nil
}

extension EnvironmentValues {
	var customWindowPresentation: CustomWindowPresentation? {
		get { self[CustomWindowPresentationKey.self] }
		set { self[CustomWindowPresentationKey.self] = newValue }
	}
}
