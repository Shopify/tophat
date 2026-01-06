//
//  URL+Extensions.swift
//  Tophat
//
//  Created by Harley Cooper on 1/19/23.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation

public extension URL {
    func appending<S>(paths: [S], directoryHint: URL.DirectoryHint = .inferFromPath) -> URL where S: StringProtocol {
        return paths.reduce(self) { $0.appending(path: $1, directoryHint: directoryHint) }
    }

    func isReachable() -> Bool {
        guard let result = try? checkResourceIsReachable() else {
            return false
        }

        return result
    }

    nonisolated func calculateSizeInBytes() async throws -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: self,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        let files = enumerator.compactMap { $0 as? URL }

        let nonDirectoryFiles = files.filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == false
        }

        return try nonDirectoryFiles.reduce(0) { total, url in
            guard let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                return total
            }

            return total + Int64(fileSize)
        }
    }

    /// Returns the full (compound) extension of the file, e.g. "tar.gz" for "foo.tar.gz".
    var fullPathExtension: String {
        let name = lastPathComponent
        let components = name.split(separator: ".")
        guard components.count > 1 else { return "" }
        // Remove the first component (filename), join the rest
        return components.dropFirst().joined(separator: ".")
    }

    /// Returns the filename without the full (compound) extension.
    var deletingFullPathExtension: String {
        let ext = fullPathExtension
        guard !ext.isEmpty else { return lastPathComponent }
        return String(lastPathComponent.dropLast(ext.count + 1))
    }

    /// Returns the filename without the last path extension (single extension only).
    var fileName: String {
        let ext = pathExtension
        guard !ext.isEmpty else { return lastPathComponent }
        return String(lastPathComponent.dropLast(ext.count + 1))
    }

    /// Returns the filename without any extension (removes everything after the first dot).
    var fileRoot: String {
        return lastPathComponent.components(separatedBy: ".").first ?? lastPathComponent
    }
}
