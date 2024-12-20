//
//  ArtifactDownloaderError.swift
//  TophatModules
//
//  Created by Ben Scheirman on 12/20/24.
//  Copyright © 2024 Nike. All rights reserved.
//

public enum ArtifactDownloaderError: Error {
	case failedToDownloadArtifact(reason: String)
	case untrustedHost
}
