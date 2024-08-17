//
//  String+WrappedInQuotationMarks.swift
//  ShellKit
//
//  Created by Lukas Romsicki on 2022-10-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

public extension String {
	func wrappedInQuotationMarks() -> String {
		"\"\(self)\""
	}
}
