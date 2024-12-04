//
//  ArtifactProviderMetadata.swift
//  TophatFoundation
//
//  Created by Lukas Romsicki on 2024-11-21.
//

/// The metadata required to retrieve a artifact from a artifact provider.
public struct ArtifactProviderMetadata: Sendable, Equatable, Hashable, Codable {
	/// The identifier of the artifact provider that should retrieve the artifact.
	public let id: String

	/// The parameters passed to the artifact provider used to retrieve the artifact.
	public let parameters: [String: String]

	public init(id: String, parameters: [String: String]) {
		self.id = id
		self.parameters = parameters
	}
}
