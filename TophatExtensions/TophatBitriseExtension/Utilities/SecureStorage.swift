//
//  SecureStorage.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
import Observation
import SimpleKeychain

@propertyWrapper
public struct SecureStorage: DynamicProperty {
	private let key: String
	private let keychain = SimpleKeychain()

	@State private var value: String?

	public init(_ key: String) {
		self.key = key
		self._value = State(initialValue: try? keychain.string(forKey: key))
	}

	public var wrappedValue: String? {
		get { value }
		nonmutating set {
			if let newValue {
				try? keychain.set(newValue, forKey: key)
			} else {
				try? keychain.deleteItem(forKey: key)
			}

			value = newValue
		}
	}

	public var projectedValue: Binding<String?> {
		Binding {
			wrappedValue
		} set: { newValue in
			wrappedValue = newValue
		}
	}
}
