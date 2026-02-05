//
//  SettingsView.swift
//  TophatGitHubActionsExtension
//
//  Created by Doan Thieu on 24/12/25.
//  Copyright © 2025 Shopify. All rights reserved.
//

import SwiftUI
import SecureStorage
import TophatKit

struct SettingsView: View {
	@SecureStorage(Constants.keychainGitHubPersonalAccessTokenKey) var storedPersonalAccessToken: String?
	@State private var enteredPersonalAccessToken = ""

	var body: some View {
		Form {
			Section("Authentication") {
				SecureField("Personal Access Token", text: $enteredPersonalAccessToken, prompt: Text("Token"))

				Text("To create a personal access token, go to [github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens).")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
		.formStyle(.grouped)
		.onAppear {
			enteredPersonalAccessToken = storedPersonalAccessToken ?? ""
		}
		.onChange(of: enteredPersonalAccessToken) { _, newValue in
			storedPersonalAccessToken = newValue.isEmpty ? nil : newValue
		}
	}
}
