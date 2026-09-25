import Foundation
import Testing
import TophatControlServices

struct UserSpecifiedQuickLaunchEntryConfigurationTests {
	@Test(arguments: ["Example-app-123", "0", "12345678-1234-1234-1234-123456789ABC"])
	func preservesValidIdentifiersAndDisplayNames(id: String) throws {
		let data = try JSONSerialization.data(withJSONObject: configuration(id: id))
		let configuration = try JSONDecoder().decode(UserSpecifiedQuickLaunchEntryConfiguration.self, from: data)
		let request = AddQuickLaunchEntryRequest(configuration: configuration)
		let received = try JSONDecoder().decode(AddQuickLaunchEntryRequest.self, from: JSONEncoder().encode(request))

		#expect(received.configuration.id == id)
		#expect(received.configuration.name == "Example 应用")
		#expect(received.configuration.recipes.count == 1)
		#expect(received.configuration.recipes.first?.artifactProviderID == "example")
	}

	@Test(arguments: [
		"", ".", "..", "../icon", "/icon", "app/icon", "app\\icon",
		"app.name", "app_name", "app name", "äpp", "应用", "app\n", "app\0", "%2e%2e"
	])
	func rejectsInvalidIdentifiersInConfigurationsAndRequests(id: String) throws {
		let configuration = configuration(id: id)
		let data = try JSONSerialization.data(withJSONObject: configuration)
		#expect(throws: DecodingError.self) {
			try JSONDecoder().decode(UserSpecifiedQuickLaunchEntryConfiguration.self, from: data)
		}

		let requestData = try JSONSerialization.data(withJSONObject: [
			"id": "12345678-1234-1234-1234-123456789ABC",
			"configuration": configuration
		])
		#expect(throws: DecodingError.self) {
			try JSONDecoder().decode(AddQuickLaunchEntryRequest.self, from: requestData)
		}
	}

	private func configuration(id: String) -> [String: Any] {
		[
			"id": id,
			"name": "Example 应用",
			"recipes": [[
				"artifactProviderID": "example",
				"artifactProviderParameters": [:],
				"launchArguments": [],
				"platformHint": "ios"
			]]
		]
	}
}
