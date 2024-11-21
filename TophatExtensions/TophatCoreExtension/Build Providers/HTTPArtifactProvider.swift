//
//  HTTPArtifactProvider.swift
//  TophatCoreExtension
//
//  Created by Lukas Romsicki on 2024-10-05.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatKit

struct HTTPArtifactProvider: ArtifactProvider {
	static let id = "http"
	static let title: LocalizedStringResource = "Basic HTTP"

	@Parameter(key: "url", title: "URL")
	var url: URL

	func retrieve() async throws -> some ArtifactProviderResult {
		let (downloadedFileURL, response) = try await URLSession.shared.download(from: url)

		let destinationDirectoryURL: URL = .temporaryDirectory.appending(path: UUID().uuidString)
		try FileManager.default.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)

		let destinationURL = destinationDirectoryURL
			.appending(component: response.suggestedFilename ?? url.lastPathComponent)

		try FileManager.default.moveItem(at: downloadedFileURL, to: destinationURL)

		return .result(localURL: destinationURL)
	}

	func cleanUp(localURL: URL) async throws {
		try FileManager.default.removeItem(at: localURL)
	}
}
