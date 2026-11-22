//
//  Aapt2OutputParser.swift
//  AndroidDeviceKit
//
//  Created by Jared Hendry on 2026-11-15.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import RegexBuilder

enum Aapt2OutputParser {
	private static let androidIconAttributeID = "0x01010002"
	private static let iconReferenceMarker = "(\(androidIconAttributeID))=@"

	nonisolated(unsafe) private static let resourceIDRegex = Regex {
		"0x"
		Repeat(.hexDigit, count: 8)
	}

	static func iconResourceID(inManifestTree manifestTree: String) -> String? {
		var isInsideApplication = false

		for line in manifestTree.split(whereSeparator: \.isNewline) {
			let content = line.drop { $0 == " " }

			if content.hasPrefix("E: ") {
				// Attributes always precede child elements, so reaching another element
				// means the application element has no icon.
				if isInsideApplication {
					return nil
				}

				isInsideApplication = content.hasPrefix("E: application ")
			} else if isInsideApplication, let markerRange = content.range(of: iconReferenceMarker) {
				let value = content[markerRange.upperBound...].prefix { $0 != " " }
				return value.wholeMatch(of: resourceIDRegex).map { String($0.output) }
			}
		}

		return nil
	}

	static func iconPath(inResourceTable resourceTable: String, resourceID: String) -> String? {
		let lines = resourceTable.split(whereSeparator: \.isNewline).map { $0.drop { $0 == " " } }
		var visitedResources: Set<ResourceReference> = []

		return rasterPath(of: .id(Substring(resourceID)), in: lines, visitedResources: &visitedResources)
	}

	private static func rasterPath(
		of resource: ResourceReference,
		in lines: [Substring],
		visitedResources: inout Set<ResourceReference>
	) -> String? {
		guard visitedResources.insert(resource).inserted else {
			return nil
		}

		let entries = sortedByDensityPreference(candidateEntries(of: resource, in: lines))

		for entry in entries {
			if let raster = RasterFile(entry: entry) {
				return String(raster.path)
			}

			if let reference = ResourceReference(entry: entry),
			   let path = rasterPath(of: reference, in: lines, visitedResources: &visitedResources) {
				return path
			}
		}

		return nil
	}

	private static func candidateEntries(of resource: ResourceReference, in lines: [Substring]) -> [Entry] {
		guard let headerIndex = lines.firstIndex(where: resource.matchesHeader) else {
			return []
		}

		return lines[(headerIndex + 1)...]
			.prefix { $0.hasPrefix("(") }
			.compactMap(Entry.init(line:))
			.filter(\.variesOnlyByDensityOrVersion)
	}

	private static func sortedByDensityPreference(_ entries: [Entry]) -> [Entry] {
		let anyDensityEntries = entries.filter(\.isAnyDensity)
		let specificDensityEntries = entries.filter { !$0.isAnyDensity }

		let atLeastPreferredDensityEntries = specificDensityEntries
			.filter(\.isAtLeastPreferredDensity)
			.sorted { $0.density < $1.density }

		let belowPreferredDensityEntries = specificDensityEntries
			.filter { !$0.isAtLeastPreferredDensity }
			.sorted { $0.density > $1.density }

		return anyDensityEntries + atLeastPreferredDensityEntries + belowPreferredDensityEntries
	}
}

extension Aapt2OutputParser {
	private struct Entry {
		private static let defaultDensity = 160
		private static let preferredDensity = 480
		private static let anyDensity = 65534
		private static let noDensity = 65535

		private static let namedDensities: [String: Int] = [
			"ldpi": 120,
			"mdpi": 160,
			"tvdpi": 213,
			"hdpi": 240,
			"xhdpi": 320,
			"xxhdpi": 480,
			"xxxhdpi": 640,
			"anydpi": anyDensity,
			"nodpi": noDensity
		]

		let qualifiers: [Substring]
		let value: Substring

		var density: Int {
			qualifiers.lazy.compactMap(Self.density(of:)).first ?? Self.defaultDensity
		}

		var isAnyDensity: Bool {
			density == Self.anyDensity
		}

		var isAtLeastPreferredDensity: Bool {
			density >= Self.preferredDensity
		}

		var variesOnlyByDensityOrVersion: Bool {
			qualifiers.allSatisfy(Self.isDensityOrVersion)
		}

		init?(line: Substring) {
			guard line.hasPrefix("("), let configurationEnd = line.range(of: ") ") else {
				return nil
			}

			self.qualifiers = line[line.index(after: line.startIndex)..<configurationEnd.lowerBound].split(separator: "-")
			self.value = line[configurationEnd.upperBound...]
		}

		private static func density(of qualifier: Substring) -> Int? {
			if let density = namedDensities[String(qualifier)] {
				return density
			}

			guard qualifier.hasSuffix("dpi") else {
				return nil
			}

			return Int(qualifier.dropLast(3))
		}

		private static func isDensityOrVersion(_ qualifier: Substring) -> Bool {
			density(of: qualifier) != nil
				|| (qualifier.first == "v" && Int(qualifier.dropFirst()) != nil)
		}
	}

	private struct RasterFile {
		private static let fileMarker = "(file) "

		private static let extensions: Set<String> = ["png", "webp", "jpg", "jpeg", "gif"]

		let path: Substring

		init?(entry: Entry) {
			guard entry.value.hasPrefix(Self.fileMarker) else {
				return nil
			}

			let path = entry.value.dropFirst(Self.fileMarker.count).prefix { $0 != " " }

			guard let fileExtension = path.split(separator: ".").last, Self.extensions.contains(fileExtension.lowercased()) else {
				return nil
			}

			self.path = path
		}
	}

	private enum ResourceReference: Hashable {
		case id(Substring)
		case name(Substring)

		init?(entry: Entry) {
			guard entry.value.hasPrefix("@") else {
				return nil
			}

			let target = entry.value.dropFirst().prefix { $0 != " " }

			if target.wholeMatch(of: resourceIDRegex) != nil {
				self = .id(target)
			} else if target.contains("/"), !target.contains(":") {
				self = .name(target)
			} else {
				return nil
			}
		}

		func matchesHeader(_ line: Substring) -> Bool {
			guard line.hasPrefix("resource ") else {
				return false
			}

			let fields = line.split(separator: " ", maxSplits: 3)

			guard fields.count >= 3 else {
				return false
			}

			switch self {
				case .id(let id):
					return fields[1] == id
				case .name(let name):
					return fields[2] == name
			}
		}
	}
}
