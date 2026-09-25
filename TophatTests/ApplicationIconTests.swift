import Foundation
import Testing
@testable import Tophat

struct ApplicationIconTests {
	@Test(arguments: [
		"", ".", "..", "../icon", "/icon", "app/icon", "app\\icon",
		"app.name", "app_name", "app name", "äpp", "应用", "app\n", "app\0", "%2e%2e"
	])
	func rejectsInvalidIdentifiers(id: String) throws {
		let directory = try makeDirectory()
		defer { try? FileManager.default.removeItem(at: directory) }
		let icons = directory.appending(component: "icons")
		try FileManager.default.createDirectory(at: icons, withIntermediateDirectories: true)
		let source = directory.appending(component: "source")
		let victim = directory.appending(component: "victim")
		try Data("new icon".utf8).write(to: source)
		try Data("unchanged".utf8).write(to: victim)

		#expect(throws: ApplicationIconError.invalidIdentifier) {
			try ApplicationIcon.createAndPersist(fromOrigin: source, for: id, directoryURL: icons)
		}
		#expect(try Data(contentsOf: victim) == Data("unchanged".utf8))
		#expect(try FileManager.default.contentsOfDirectory(atPath: icons.path).isEmpty)
	}

	@Test(arguments: ["Example-app-123", "0", "12345678-1234-1234-1234-123456789ABC"])
	func replacesIconWithinDirectory(id: String) throws {
		let directory = try makeDirectory()
		defer { try? FileManager.default.removeItem(at: directory) }
		let source = directory.appending(component: "source")
		let destination = directory.appending(component: id)
		let contents = Data("new icon".utf8)
		try contents.write(to: source)
		try Data("old icon".utf8).write(to: destination)

		let icon = try ApplicationIcon.createAndPersist(fromOrigin: source, for: id, directoryURL: directory)

		#expect(icon.url == destination)
		#expect(try Data(contentsOf: destination) == contents)
		#expect(try Data(contentsOf: source) == contents)
	}

	@Test(arguments: [false, true])
	func doesNotOverwriteSymbolicLinkTargetOutsideDirectory(relativeLink: Bool) throws {
		let directory = try makeDirectory()
		defer { try? FileManager.default.removeItem(at: directory) }
		let icons = directory.appending(component: "icons")
		try FileManager.default.createDirectory(at: icons, withIntermediateDirectories: true)
		let source = directory.appending(component: "source")
		let victim = directory.appending(component: "victim")
		try Data("new icon".utf8).write(to: source)
		try Data("unchanged".utf8).write(to: victim)
		try FileManager.default.createSymbolicLink(
			atPath: icons.appending(component: "app").path,
			withDestinationPath: relativeLink ? "../victim" : victim.path
		)

		do {
			_ = try ApplicationIcon.createAndPersist(fromOrigin: source, for: "app", directoryURL: icons)
		} catch {
			#expect(error is CocoaError)
		}
		#expect(try Data(contentsOf: victim) == Data("unchanged".utf8))
		#expect(try Data(contentsOf: source) == Data("new icon".utf8))
	}

	private func makeDirectory() throws -> URL {
		let directory = FileManager.default.temporaryDirectory
			.appending(component: UUID().uuidString, directoryHint: .isDirectory)
			.resolvingSymlinksInPath()
		try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
		return directory
	}
}
