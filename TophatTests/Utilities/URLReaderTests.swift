//
//  URLReaderTests.swift
//  TophatTests
//
//  Created by Lukas Romsicki on 2024-09-26.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Testing
import Foundation
import TophatFoundation

@testable import Tophat

struct URLReaderTests {
	static let urlPrefixes = [
		"http://localhost:1234/",
		"tophat://"
	]

	@Test("Handles local files")
	func handlesLocalFiles() async throws {
		let url: URL = .documentsDirectory.appending(path: "test.zip")
		let result = try result(url: url)

		#expect(result == .localFile(url: url))
	}

	@Test("Throws for unsupported scheme")
	func throwsForUnsupportedScheme() async throws {
		let url = URL(string: "other://test")!

		#expect(throws: URLReaderError.unsupportedURL(url)) {
			try result(url: url)
		}
	}

	@Test("Throws for unsupported route", arguments: urlPrefixes)
	func throwsForUnsupportedRoute(urlPrefix: String) async throws {
		let url = url(prefix: urlPrefix, path: "unsupported")

		#expect(throws: URLReaderError.unsupportedURL(url)) {
			try result(url: url)
		}
	}

	@Test("Handles basic install route", arguments: urlPrefixes)
	func handlesBasicInstallRoute(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=a&two=b"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "a", "two": "b"]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Handles basic install route with platform hint", arguments: urlPrefixes, Platform.allCases)
	func handlesBasicInstallRouteWithPlatformHint(urlPrefix: String, platform: Platform) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=a&two=b&platform=\(platform.rawValue)"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "a", "two": "b"]
					)
				),
				launchArguments: [],
				platformHint: platform,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Handles basic install route with destination hint", arguments: urlPrefixes, ["simulator", "device"])
	func handlesBasicInstallRouteWithDestinationHint(urlPrefix: String, destination: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=a&two=b&destination=\(destination)"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "a", "two": "b"]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: destination == "simulator" ? .simulator : .device
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Handles install route with no parameters", arguments: urlPrefixes)
	func handlesInstallRouteWithNoParameters(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: [:]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Handles install route with hint parameter but no artifact provider parameters", arguments: urlPrefixes)
	func handlesInstallRouteWithHintParameterNoArtifactProviderParameters(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?platform=ios"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: [:]
					)
				),
				launchArguments: [],
				platformHint: .iOS,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Handles install route with repeated parameters", arguments: urlPrefixes)
	func handlesInstallRouteWithRepeatedParameters(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=a&two=b&one=c&two=d"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "a", "two": "b"]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: nil
			),
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "c", "two": "d"]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Throws on install route if repeated parameters are unbalanced", arguments: urlPrefixes)
	func throwsOnInstallRouteIfRepeatedParametersUnbalanced(urlPrefix: String) async throws {
		let url = url(prefix: urlPrefix, path: "install/test?one=a&two=b&one=c")

		#expect(throws: URLReaderError.malformedURL(url)) {
			try result(url: url)
		}
	}

	@Test("Handles install route with one set of optional parameters", arguments: urlPrefixes)
	func handlesInstallRouteOneSetOptionalParameters(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=a&two=b&platform=ios&destination=simulator&arguments=one,two&one=c&two=d"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "a", "two": "b"]
					)
				),
				launchArguments: ["one", "two"],
				platformHint: .iOS,
				destinationHint: .simulator
			),
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "c", "two": "d"]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Handles install route with all parameters", arguments: urlPrefixes)
	func handlesInstallRouteAllParameters(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=a&two=b&platform=ios&destination=simulator&arguments=one,two&one=c&two=d&platform=android&destination=device&arguments=three,four"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "a", "two": "b"]
					)
				),
				launchArguments: ["one", "two"],
				platformHint: .iOS,
				destinationHint: .simulator
			),
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "c", "two": "d"]
					)
				),
				launchArguments: ["three", "four"],
				platformHint: .android,
				destinationHint: .device
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Removes percent encoding from parameter values", arguments: urlPrefixes)
	func removesPercentEncodingFromParameterValues(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=a%20b"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "a b"]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	@Test("Preserves double percent encoded parameter values", arguments: urlPrefixes)
	func preservesDoublePercentEncodedParameterValues(urlPrefix: String) async throws {
		let result = try result(url: url(prefix: urlPrefix, path: "install/test?one=http%3A%2F%2Fexample.com%2Fpath%3Fvalue%3Da%2520b"))

		let expectedRequests: [InstallRecipe] = [
			.init(
				source: .artifactProvider(
					metadata: .init(
						id: "test",
						parameters: ["one": "http://example.com/path?value=a%20b"]
					)
				),
				launchArguments: [],
				platformHint: nil,
				destinationHint: nil
			)
		]

		#expect(result == .install(requests: expectedRequests))
	}

	private func url(prefix: String, path: String) -> URL {
		URL(string: "\(prefix)\(path)")!
	}

	private func result(url: URL) throws -> URLReaderResult {
		try URLReader().read(url: url)
	}
}
