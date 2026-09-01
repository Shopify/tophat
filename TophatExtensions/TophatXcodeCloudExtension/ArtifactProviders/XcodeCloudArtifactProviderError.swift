//
//  XcodeCloudArtifactProviderError.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation

enum XcodeCloudArtifactProviderError: Error {
	case credentialsNotSet
	case invalidPrivateKey
	case unauthorized
	case forbidden
	case buildRunNotFound
	case artifactNotFound
	case artifactNotReady
	case artifactExpired
	case unexpected
}

extension XcodeCloudArtifactProviderError: LocalizedError {
	var errorDescription: String? {
		"Failed to Download Artifact"
	}

	var failureReason: String? {
		switch self {
			case .credentialsNotSet:
				"An App Store Connect API key is required."
			case .invalidPrivateKey:
				"The private key used to authenticate with App Store Connect could not be read."
			case .unauthorized:
				"The API key used to authenticate with App Store Connect is invalid."
			case .forbidden:
				"The API key does not have permission to read Xcode Cloud builds."
			case .buildRunNotFound:
				"The requested Xcode Cloud build was not found."
			case .artifactNotFound:
				"The Xcode Cloud build did not produce the requested artifact."
			case .artifactNotReady:
				"The build products for this Xcode Cloud build are not available yet."
			case .artifactExpired:
				"The build products for this Xcode Cloud build are no longer available. They may have expired."
			case .unexpected:
				"Something went wrong that Tophat wasn’t able to identify."
		}
	}

	var recoverySuggestion: String? {
		switch self {
			case .credentialsNotSet:
				"Go to Tophat Settings → Extensions → Xcode Cloud to add an API key."
			case .invalidPrivateKey:
				"Go to Tophat Settings → Extensions → Xcode Cloud and paste the contents of the .p8 file again."
			case .unauthorized:
				"Go to Tophat Settings → Extensions → Xcode Cloud to update the API key."
			case .forbidden:
				"Create a team API key with a role that can read Xcode Cloud builds and add it in Tophat Settings → Extensions → Xcode Cloud."
			case .buildRunNotFound:
				"Check that the build still exists and has not been deleted."
			case .artifactNotFound:
				"Check the artifact name against the artifacts listed for the build in App Store Connect."
			case .artifactNotReady:
				"Wait for the build to finish and try again."
			case .artifactExpired:
				"Start a new build in Xcode Cloud to produce fresh build products."
			case .unexpected:
				"Try again later."
		}
	}
}
