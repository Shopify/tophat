//
//  SecureStorage.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
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
