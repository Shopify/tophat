//
//  ArtifactProvider.swift
//  TophatKit
//
//  Created by Lukas Romsicki on 2024-09-06.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation

/// The type you use to define a mechanism for retrieving artifacts for installation
/// with Tophat.
///
/// Create a ``ArtifactProvider`` for each type of artifact source, such as for retrieving
/// from the local filesystem, a continuous integration provider, or cloud storage provider.
/// If the source requires authentication, handle it in the ``retrieve()`` function as
/// well.
public protocol ArtifactProvider {
	associatedtype Result = ArtifactProviderResult
	typealias Parameter = ArtifactProviderParameter

	/// The unique identifier of the artifact provider.
	///
	/// Tophat exposes this value through its own interfaces or in the graphical
	/// user interface so that people can specify which provider to use when
	/// retrieving an artifact.
	static var id: String { get }

	/// A human-readable title for this artifact provider.
	static var title: LocalizedStringResource { get }

	init()

	/// The function used to retrieve the artifact.
	///
	/// Throw any errors if they ocurred. Use any parameters wrapped with ``Parameter`` to
	/// collect inputs from Tophat to implement the retrieval mechanism.
	///
	/// To display an error message in the user interface, conform thrown errors to the
	/// `LocalizedError` protocol.
	/// - Returns: A ``ArtifactProviderResult`` containing the output.
	func retrieve() async throws -> Result

	/// The function used to clean up the downloaded artifact once it is no longer needed.
	/// - Parameter localURL: The URL of the local resource that should be cleaned up.
	func cleanUp(localURL: URL) async throws
}
