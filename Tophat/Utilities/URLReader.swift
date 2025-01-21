//
//  URLReader.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

enum URLReaderResult: Equatable {
	case localFile(url: URL)
	case install(requests: [InstallRecipe])
}

struct URLReader {
	func read(url: URL) throws -> URLReaderResult {
		if url.isFileURL {
			return .localFile(url: url)
		}

		switch url.scheme {
			case "tophat":
				return try read(tophatURL: url)
			case "http":
				return try read(httpURL: url)
			default:
				throw URLReaderError.unsupportedURL(url)
		}
	}

	private func read(tophatURL url: URL) throws -> URLReaderResult {
		// We don't use a host, we just pretend that the path starts right after the protocol.
		// The first path item is actually interpreted as the host.
		switch url.host() {
			case "install":
				return try read(installURL: url)
			default:
				throw URLReaderError.unsupportedURL(url)
		}
	}

	private func read(httpURL url: URL) throws -> URLReaderResult {
		// The first path component is the leading forward slash.
		switch url.pathComponents.dropFirst().first {
			case "install":
				return try read(installURL: url)
			default:
				throw URLReaderError.unsupportedURL(url)
		}
	}

	private func read(installURL url: URL) throws -> URLReaderResult {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			throw URLReaderError.malformedURL(url)
		}

		let queryItems = components.queryItems ?? []

		let binnedQueryItemValues = Dictionary(grouping: queryItems) { element in
			element.name
		}.mapValues { items in
			items.compactMap(\.value)
		}

		let parameterQueryItemValues = binnedQueryItemValues.filter { element in
			element.key != "platform" && element.key != "destination" && element.key != "arguments"
		}

		let valueCount = parameterQueryItemValues.values.first?.count ?? 0

		if valueCount == 0, binnedQueryItemValues.values.contains(where: { $0.count > 1 }) {
			throw URLReaderError.malformedURL(url)
		}

		if parameterQueryItemValues.isEmpty {
			return .install(
				requests: [
					installRecipe(
						at: 0,
						in: binnedQueryItemValues,
						artifactProviderID: url.lastPathComponent
					)
				]
			)
		}

		guard parameterQueryItemValues.allSatisfy({ $1.count == valueCount }) else {
			throw URLReaderError.malformedURL(url)
		}

		let installRequests = (0..<valueCount).map { index in
			return installRecipe(
				at: index,
				in: binnedQueryItemValues,
				artifactProviderID: url.lastPathComponent
			)
		}

		return .install(requests: installRequests)
	}

	private func installRecipe(
		at index: Int,
		in binnedQueryItemValues: [String: [String]],
		artifactProviderID: String
	) -> InstallRecipe {
		let parameters: [String: String] = binnedQueryItemValues.reduce(into: [:]) { partialResult, item in
			if item.key != "platform", item.key != "destination", item.key != "arguments" {
				partialResult[item.key] = item.value[index]
			}
		}

		let platform: Platform? = if let platformString = binnedQueryItemValues["platform"]?[safe: index] {
			Platform(rawValue: platformString)
		} else {
			nil
		}

		let destination: DeviceType? = if let destinationString = binnedQueryItemValues["destination"]?[safe: index] {
			destinationString == "device" ? .device : .simulator
		} else {
			nil
		}

		let launchArguments = binnedQueryItemValues["arguments"]?[safe: index]?
			.split(separator: ",", omittingEmptySubsequences: true)
			.map(String.init)
			.compactMap(\.removingPercentEncoding)

		return InstallRecipe(
			source: .artifactProvider(
				metadata: ArtifactProviderMetadata(
					id: artifactProviderID,
					parameters: parameters
				)
			),
			launchArguments: launchArguments ?? [],
			platformHint: platform,
			destinationHint: destination
		)
	}
}

enum URLReaderError: Error, Equatable {
	case malformedURL(URL)
	case unsupportedURL(URL)
}
