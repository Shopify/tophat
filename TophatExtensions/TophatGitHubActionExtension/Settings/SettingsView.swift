//
//  SettingsView.swift
//  TophatGitHubActionExtension
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

                Text("To learn more about GitHub's personal access token, visit [Managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            enteredPersonalAccessToken = storedPersonalAccessToken ?? ""
        }
        .onChange(of: enteredPersonalAccessToken) { oldValue, newValue in
            storedPersonalAccessToken = newValue.isEmpty ? nil : newValue
        }
    }
}
