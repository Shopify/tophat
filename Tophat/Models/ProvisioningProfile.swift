//
//  ProvisioningProfile.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-02.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

struct ProvisioningProfile: Decodable {
	let name: String
	let appIDName: String
	let teamName: String
	let provisionedDevices: [String]?
	let provisionsAllDevices: Bool?

	private enum CodingKeys: String, CodingKey {
		case name = "Name"
		case appIDName = "AppIDName"
		case teamName = "TeamName"
		case provisionedDevices = "ProvisionedDevices"
		case provisionsAllDevices = "ProvisionsAllDevices"
	}
}

extension ProvisioningProfile {
	/// `mobileprovision` files contain binary data but also include a property list as plain text. This initializer
	/// extracts the property list without using `security` to decode the file.
	/// - Parameter url: The URL of the `mobileprovision` file on the local file system.
	init?(url: URL) {
		guard let fileContents = try? String(contentsOf: url, encoding: .isoLatin1) else {
			return nil
		}

		let scanner = Scanner(string: fileContents)

		guard
			scanner.scanUpToString("<plist") != nil,
			let plistString = scanner.scanUpToString("</plist>")?.appending("</plist>"),
			let plistData = plistString.data(using: .isoLatin1),
			let instance = try? PropertyListDecoder().decode(ProvisioningProfile.self, from: plistData)
		else {
			return nil
		}

		self = instance
	}
}
