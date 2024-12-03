//
//  AvdManager.swift
//  AndroidDeviceKit
//
//  Created by Lukas Romsicki on 2022-10-24.
//  Copyright © 2022 Shopify. All rights reserved.
//

import ShellKit
import RegexBuilder

struct AvdManager {
	static func listVirtualDevices() -> [VirtualDevice] {
		guard let output = try? run(command: .avdManager(.listAvd), log: log) else {
			return []
		}

		return output
			.split(separator: "---------")
			.compactMap { VirtualDevice(from: String($0)) }
	}
}

private extension VirtualDevice {
	nonisolated(unsafe) private static let anyWhitespace = OneOrMore(.whitespace)
	nonisolated(unsafe) private static let characterOrSymbolCapture = Capture {
		OneOrMore(CharacterClass.anyNonNewline)
	}

	nonisolated(unsafe) private static let search = Regex {
		"Name: "
		characterOrSymbolCapture
		anyWhitespace
		"Device: "
		characterOrSymbolCapture
		anyWhitespace
		"Path: "
		characterOrSymbolCapture
		anyWhitespace
		"Target: "
		characterOrSymbolCapture
		anyWhitespace
		"Based on: "
		characterOrSymbolCapture
		anyWhitespace
		"Tag/ABI: "
		characterOrSymbolCapture
		anyWhitespace
		Optionally {
			"Skin: "
			characterOrSymbolCapture
			anyWhitespace
		}
		Optionally {
			"Sdcard: "
			characterOrSymbolCapture
			anyWhitespace
		}
		Optionally {
			"Snapshot: "
			TryCapture {
				ChoiceOf {
					"yes"
					"no"
				}
			} transform: { $0 == "yes" }
		}
	}

	init?(from payload: String) {
		guard let output = payload.firstMatch(of: Self.search)?.output else {
			return nil
		}

		let (_, name, device, path, target, basedOn, tagAbi, skin, sdCard, snapshot) = output

		self.name = String(name)
		self.device = String(device)
		self.path = String(path)
		self.target = String(target)
		self.androidVersion = String(basedOn)
		self.abi = String(tagAbi)

		if let skin = skin {
			self.skin = String(skin)
		} else {
			self.skin = nil
		}

		if let sdCard = sdCard {
			self.sdCard = String(sdCard)
		} else {
			self.sdCard = nil
		}

		self.snapshot = snapshot
	}
}
