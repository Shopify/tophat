//
//  SettingsView.swift
//  Tophat
//
//  Created by Jonathan Seed on 2026-09-23.
//  Copyright © 2026 Shopify. All rights reserved.
//


import SwiftUI
import TophatKit

struct SettingsView: View {
    @SecureStorage(Constants.keychainGitLabPersonalAccessTokenKey) var storedPersonalAccessToken: String?
    @State private var enteredPersonalAccessToken = ""

    var body: some View {
        Form {
            Section("Authentication") {
                SecureField("Personal Access Token", text: $enteredPersonalAccessToken, prompt: Text("Token"))

                Text("To create a personal access token, go to [gitlab.com/-/user_settings/personal_access_tokens](https://gitlab.com/-/user_settings/personal_access_tokens).")
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
