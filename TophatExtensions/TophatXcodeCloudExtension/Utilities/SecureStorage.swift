//
//  SecureStorage.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import SwiftUI
import SimpleKeychain

@propertyWrapper
struct SecureStorage {
	private let key: String
	private let keychain = SimpleKeychain()

	init(_ key: String) {
		self.key = key
	}

	var wrappedValue: String? {
		get {
			try? keychain.string(forKey: key)
		}
		nonmutating set {
			if let newValue {
				try? keychain.set(newValue, forKey: key)
			} else {
				try? keychain.deleteItem(forKey: key)
			}
		}
	}
}
