//
//  SettingsView.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import SwiftUI
import TophatKit

struct SettingsView: View {
	@SecureStorage(Constants.keychainIssuerIDKey) var storedIssuerID: String?
	@SecureStorage(Constants.keychainKeyIDKey) var storedKeyID: String?
	@SecureStorage(Constants.keychainPrivateKeyKey) var storedPrivateKey: String?

	@State private var enteredIssuerID = ""
	@State private var enteredKeyID = ""
	@State private var enteredPrivateKey = ""

	var body: some View {
		Form {
			Section("Authentication") {
				TextField("Issuer ID", text: $enteredIssuerID, prompt: Text("Issuer ID"))
				TextField("Key ID", text: $enteredKeyID, prompt: Text("Key ID"))
				SecureField("Private Key", text: $enteredPrivateKey, prompt: Text("Contents of the .p8 file"))

				Text("To create a team API key, go to [appstoreconnect.apple.com/access/integrations/api](https://appstoreconnect.apple.com/access/integrations/api).")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
		.formStyle(.grouped)
		.onAppear {
			enteredIssuerID = storedIssuerID ?? ""
			enteredKeyID = storedKeyID ?? ""
			enteredPrivateKey = storedPrivateKey ?? ""
		}
		.onChange(of: enteredIssuerID) { _, newValue in
			storedIssuerID = newValue.isEmpty ? nil : newValue
		}
		.onChange(of: enteredKeyID) { _, newValue in
			storedKeyID = newValue.isEmpty ? nil : newValue
		}
		.onChange(of: enteredPrivateKey) { _, newValue in
			storedPrivateKey = newValue.isEmpty ? nil : newValue
		}
	}
}
