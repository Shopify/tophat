//
//  CodableAppStorage.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-30.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import SwiftUI

@propertyWrapper
@MainActor struct CodableAppStorage<Value: Codable>: DynamicProperty {
	@ObservedObject private var store: UserDefaultsKeyStore<Value>

	init(wrappedValue defaultValue: Value, _ key: String, storage: UserDefaults = .standard) {
		self.store = UserDefaultsKeyStore(key: key, storage: storage, defaultValue: defaultValue)
	}

	public var wrappedValue: Value {
		get {
			store.get()
		}
		nonmutating set {
			store.set(newValue)
		}
	}

	public var projectedValue: Binding<Value> {
		Binding(
			get: { self.wrappedValue },
			set: { self.wrappedValue = $0 }
		)
	}

	nonisolated public mutating func update() {
	   _store.update()
	}
}

private class UserDefaultsKeyStore<Value: Codable>: NSObject, ObservableObject {
	private let key: String
	private let storage: UserDefaults
	private let defaultValue: Value

	init(key: String, storage: UserDefaults, defaultValue: Value) {
		self.key = key
		self.storage = storage
		self.defaultValue = defaultValue

		super.init()

		self.storage.addObserver(self, forKeyPath: key, options: [], context: nil)
	}

	func get() -> Value {
		guard
			let storedValue = storage.value(forKey: key),
			let data = try? JSONSerialization.data(withJSONObject: storedValue),
			let value = try? JSONDecoder().decode(Value.self, from: data)
		else {
			return defaultValue
		}

		return value
	}

	func set(_ newValue: Value) {
		guard
			let data = try? JSONEncoder().encode(newValue),
			let dictionary = try? JSONSerialization.jsonObject(with: data)
		else {
			return
		}

		storage.setValue(dictionary, forKey: key)
	}

	deinit {
		storage.removeObserver(self, forKeyPath: key)
	}

	// We want to be able to pass string key names in order to use a similar API to AppStorage.
	// swiftlint:disable block_based_kvo
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		objectWillChange.send()
	}
}
