//
//  SecureStorage.swift
//  TophatGitHubActionsExtension
//
//  Created by Doan Thieu on 5/2/26.
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
