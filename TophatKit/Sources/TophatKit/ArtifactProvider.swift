//
//  ArtifactProvider.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

/// The type you use to define a mechanism for retrieving builds for installation
/// with Tophat.
///
/// Create a ``ArtifactProvider`` for each type of build source, such as for retrieving
/// from the local filesystem, a continuous integration provider, or cloud storage provider.
/// If the source requires authentication, handle it in the ``retrieve()`` function as
/// well.
public protocol ArtifactProvider {
	associatedtype Result = ArtifactProviderResult
	typealias Parameter = ArtifactProviderParameter

	/// The unique identifier of the build provider.
	///
	/// Tophat exposes this value through its own interfaces or in the graphical
	/// user interface so that people can specify which provider to use when
	/// retrieving a build.
	static var id: String { get }

	/// A human-readable title for this build provider.
	static var title: LocalizedStringResource { get }

	init()

	/// The function used to retrieve the build.
	///
	/// Throw any errors if they ocurred. Use any parameters wrapped with ``Parameter`` to
	/// collect inputs from Tophat to implement the retrieval mechanism.
	/// - Returns: A ``ArtifactProviderResult`` containing the output.
	func retrieve() async throws -> Result

	/// The function used to clean up the downloaded build once it is no longer needed.
	/// - Parameter localURL: The URL of the local resource that should be cleaned up.
	func cleanUp(localURL: URL) async throws
}
