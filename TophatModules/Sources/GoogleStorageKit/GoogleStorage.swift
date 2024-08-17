//
//  GoogleStorage.swift
//  GoogleStorageKit
//
//  Created by Jared Hendry on 2022-09-10.
//  Copyright © 2020 Shopify. All rights reserved.
//

import Foundation
import ShellKit
import RegexBuilder

public extension URL {
	var isGoogleStorageURL: Bool {
		scheme == "gs" || host() == "storage.cloud.google.com"
	}
}

public struct GoogleStorage {
	public static func download(
		artifactURL: URL,
		to localURL: URL
	) throws -> AsyncCompactMapSequence<AsyncThrowingStream<ShellOutput, Error>, DownloadProgress> {
		guard let googleStorageUrl = convertToGoogleCloudURL(url: artifactURL) else {
			throw GoogleStorageError.invalidUrl
		}

		return runAsync(command: .gsUtil(.copy(remoteUrl: googleStorageUrl, localUrl: localURL)), log: log)
			.compactMap { output in
				guard
					case .standardError(let line) = output,
					let (_, dataDownloaded, dataDownloadedUnit, totalData, totalDataUnit) = line.firstMatch(of: search)?.output
				else {
					return nil
				}

				let downloadedBytes = dataDownloaded * dataDownloadedUnit.multiplier
				let totalBytes = totalData * totalDataUnit.multiplier

				return DownloadProgress(totalUnitCount: totalBytes, pendingUnitCount: downloadedBytes)
			}
	}

	private static func convertToGoogleCloudURL(url: URL) -> URL? {
		if url.scheme == "gs" {
			// Support URLs that are already in the correct format.
			return url
		}

		if url.host != "storage.cloud.google.com" {
			return nil
		}

		guard let decodedGoogleStoragePath = url.path.removingPercentEncoding else {
			return nil
		}

		return URL(string: "gs:/\(decodedGoogleStoragePath)")
	}

	private static let dataQuantityCapture = TryCapture {
		OneOrMore(CharacterClass.anyNonNewline)
	} transform: { dataQuantity in
		Double(dataQuantity)
	}

	private static let dataUnitCapture = TryCapture {
		ChoiceOf {
			"B"
			"KiB"
			"MiB"
			"GiB"
		}
	} transform: { DownloadSizeUnit(rawValue: String($0)) }

	private static let search = Regex {
		"]["
		ZeroOrMore(.whitespace)
		dataQuantityCapture
		One(.whitespace)
		dataUnitCapture
		"/"
		dataQuantityCapture
		One(.whitespace)
		dataUnitCapture
		"]"
	}

	public struct DownloadProgress {
		public let totalUnitCount: Double
		public let pendingUnitCount: Double
	}
}

private enum DownloadSizeUnit: String {
	case bytes = "B"
	case kibibytes = "KiB"
	case mebibytes = "MiB"
	case gibibytes = "GiB"

	var multiplier: Double {
		switch self {
		case .bytes:
			return 1
		case .kibibytes:
			return 1024
		case .mebibytes:
			return 1024 * 1024
		case .gibibytes:
			return 1024 * 1024 * 1024
		}
	}
}
