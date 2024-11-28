//
//  SettingsView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-28.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
import TophatKit

struct SettingsView: View {
	@SecureStorage(Constants.keychainPersonalAccessTokenKey) var personalAccessToken: String?

	@State private var enteredPersonalAccessToken: String = ""

	var body: some View {
		Form {
			Section("Authentication") {
				SecureField("Personal Access Token", text: $enteredPersonalAccessToken, prompt: Text("Token"))

				Text("To create a personal access token, go to [app.bitrise.io/me/account/security](https://app.bitrise.io/me/account/security).")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
		.formStyle(.grouped)
		.onAppear {
			enteredPersonalAccessToken = personalAccessToken ?? ""
		}
		.onDisappear {
			personalAccessToken = enteredPersonalAccessToken
		}
	}
}
