//
//  ArtifactLocation.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2024-11-21.
//  Copyright © 2024 Shopify. All rights reserved.
//

/// The location of an artifact.
public enum ArtifactLocation {
	/// The artifact is located in a remote location, either on the web or on the local machine. A remote
	/// location is a location that is **not** controlled by Tophat.
	case remote(source: ArtifactSource)

	/// The artifact is located in a location controlled by Tophat and has already been processed.
	case local(application: Application)
}
