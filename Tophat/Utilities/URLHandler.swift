//
//  URLHandler.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import Combine

final class URLHandler {
	let onLaunchArtifactSet = PassthroughSubject<(ArtifactSet, Platform, [String]), Never>()
	let onLaunchArtifactURL = PassthroughSubject<(URL, [String]), Never>()

	func handle(urls: [URL]) throws {
		for url in urls {
			try handle(url: url)
		}
	}

	private func handle(url: URL) throws {
		switch url.scheme {
			case "file":
				onLaunchArtifactURL.send((url, []))
			case "tophat":
				try handle(tophatURL: url)
			case "http":
				try handle(httpURL: url)
			default:
				throw URLHandlerError.unsupportedURL(url)
		}
	}

	private func handle(tophatURL url: URL) throws {
		// We don't use a host, we just pretend that the path starts right after the protocol.
		// The first path item is actually interpreted as the host.
		switch url.host() {
			case "install":
				try handle(installURL: url)
			default:
				throw URLHandlerError.unsupportedURL(url)
		}
	}

	private func handle(httpURL url: URL) throws {
		// The first path component is the leading forward slash.
		switch url.pathComponents.dropFirst().first {
			case "install":
				try handle(installURL: url)
			default:
				throw URLHandlerError.unsupportedURL(url)
		}
	}

	private func handle(installURL url: URL) throws {
		guard
			let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
			let queryItems = components.queryItems
		else {
			throw URLHandlerError.malformedURL(url)
		}

		if let platform = Platform(from: url.lastPathComponent) {
			try handle(installURL: url, platform: platform, queryItems: queryItems)
		} else {
			throw URLHandlerError.malformedURL(url)
		}
	}

	private func handle(installURL url: URL, platform: Platform, queryItems: [URLQueryItem]) throws {
		let artifacts: [Artifact] = queryItems.compactMap { queryItem in
			guard
				let targets = Set(deviceTypeQueryParam: queryItem.name),
				let decodedURL = queryItem.value?.removingPercentEncoding,
				let url = URL(string: decodedURL)
			else {
				return nil
			}

			return Artifact(url: url, targets: targets)
		}

		let artifactSet = ArtifactSet(artifacts: artifacts)

		onLaunchArtifactSet.send((artifactSet, platform, launchArguments(from: queryItems)))
	}

	private func launchArguments(from queryItems: [URLQueryItem]) -> [String] {
		guard let value = queryItems.value(name: "launchArguments") else {
			return []
		}

		return value.split(separator: ",").map { String($0) }
	}
}

private extension Array where Element == URLQueryItem {
	func value(name: String) -> String? {
		first { $0.name == name }?.value
	}
}

enum URLHandlerError: Error {
	case malformedURL(URL)
	case unsupportedURL(URL)
}

private extension Set where Element == DeviceType {
	init?(deviceTypeQueryParam: String) {
		switch deviceTypeQueryParam {
			case "virtual":
				self = [.virtual]
			case "physical":
				self = [.physical]
			case "universal":
				self = [.virtual, .physical]
			default:
				return nil
		}
	}
}

private extension Platform {
	init?(from queryString: String) {
		switch queryString {
			case "ios":
				self = .iOS
			case "android":
				self = .android
			default:
				return nil
		}
	}
}
