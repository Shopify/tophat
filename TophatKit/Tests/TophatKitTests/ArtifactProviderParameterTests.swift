import Foundation
import XCTest
@testable import TophatKit

final class ArtifactProviderParameterTests: XCTestCase {
	func testMissingOptionalInputKeepsOldLinksWorkingAndClearsPreviousInput() throws {
		let provider = ScriptProvider()
		try provider.setParameters(to: ["script": "download", "input": "old-artifact"])
		try provider.setParameters(to: ["script": "download"])
		XCTAssertNil(provider.input)
	}

	func testMissingRequiredScriptStillFails() {
		let provider = ScriptProvider()
		XCTAssertThrowsError(try provider.setParameters(to: ["input": "artifact"])) { error in
			guard case ArtifactProviderError.missingParameter = error else {
				return XCTFail("Unexpected error: \(error)")
			}
		}
	}
}

private struct ScriptProvider: ArtifactProvider {
	static let id = "test-script"
	static let title: LocalizedStringResource = "Test Script"
	@Parameter(key: "script", title: "Script") var script: String
	@Parameter(key: "input", title: "Input") var input: String?

	func retrieve() async throws -> some ArtifactProviderResult {
		.result(localURL: URL(fileURLWithPath: script))
	}
	func cleanUp(localURL: URL) async throws {
		try FileManager.default.removeItem(at: localURL)
	}
}
