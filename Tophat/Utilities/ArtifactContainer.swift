//
//  ArtifactContainer.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-26.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

actor ArtifactContainer: Identifiable {
	let id: UUID
	private(set) var artifacts: [Artifact]

	var url: URL {
		.cachesDirectory
		.appending(path: Bundle.main.bundleIdentifier!, directoryHint: .isDirectory)
		.appending(path: "ArtifactContainers", directoryHint: .isDirectory)
		.appending(path: id.uuidString, directoryHint: .isDirectory)
	}

	var rawDownloads: [URL] {
		artifacts.compactMap { artifact in
			if case .rawDownload(let url) = artifact {
				return url
			} else {
				return nil
			}
		}
	}

	var applications: [Application] {
		artifacts.compactMap { artifact in
			if case .application(let application) = artifact {
				return application
			} else {
				return nil
			}
		}
	}

	init() {
		self.id = UUID()
		self.artifacts = []
	}

	func addCopy(of artifact: Artifact) throws {
		try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

		switch artifact {
			case .rawDownload(let rawDownloadURL):
				let destinationURL = url.appending(component: rawDownloadURL.lastPathComponent)
				try FileManager.default.copyItem(at: rawDownloadURL, to: destinationURL)
				artifacts.append(.rawDownload(destinationURL))

			case .application(let application):
				guard application.url.isDescendant(of: url) else {
					throw ArtifactContainerError.applicationNotCoLocated
				}

				artifacts.append(.application(application))
		}
	}
}

extension ArtifactContainer {
	enum Artifact: Sendable {
		case rawDownload(URL)
		case application(Application)
	}
}

enum ArtifactContainerError: Error {
	case applicationNotCoLocated
}

// MARK: - Deletable

extension ArtifactContainer: Deletable {
	func delete() async throws {
		try FileManager.default.removeItem(at: url)
	}
}

private extension URL {
	func isDescendant(of url: URL) -> Bool {
		let ancestorPathComponents = url.pathComponents
		let childPathComponents = self.pathComponents

		return ancestorPathComponents.count < childPathComponents.count && !zip(ancestorPathComponents, childPathComponents).contains(where: !=)
	}
}
