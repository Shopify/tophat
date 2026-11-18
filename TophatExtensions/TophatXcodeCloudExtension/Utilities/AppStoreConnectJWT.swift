//
//  AppStoreConnectJWT.swift
//  TophatXcodeCloudExtension
//
//  Created by Masahiro Kusumoto on 2026-08-25.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Foundation
import CryptoKit

/// Creates the signed JSON Web Tokens that authorize App Store Connect API requests.
///
/// App Store Connect requires every request to carry a token signed with the ES256
/// algorithm using the private key downloaded from App Store Connect.
struct AppStoreConnectJWT {
	let issuerID: String
	let keyID: String
	let privateKey: String

	/// App Store Connect rejects tokens that expire more than 20 minutes in the future.
	private static let lifetime: TimeInterval = 10 * 60

	private static let audience = "appstoreconnect-v1"
	private static let algorithm = "ES256"
	private static let type = "JWT"

	func makeToken(issuedAt: Date = Date()) throws -> String {
		let signingKey = try makeSigningKey()

		let header = Header(alg: Self.algorithm, kid: keyID, typ: Self.type)

		let payload = Payload(
			iss: issuerID,
			iat: Int(issuedAt.timeIntervalSince1970),
			exp: Int(issuedAt.addingTimeInterval(Self.lifetime).timeIntervalSince1970),
			aud: Self.audience
		)

		let encoder = JSONEncoder()

		let signingInput = [
			try encoder.encode(header).base64URLEncodedString(),
			try encoder.encode(payload).base64URLEncodedString()
		].joined(separator: ".")

		// JWT requires the raw r || s form of the signature rather than the DER encoding.
		let signature = try signingKey.signature(for: Data(signingInput.utf8))

		return "\(signingInput).\(signature.rawRepresentation.base64URLEncodedString())"
	}

	private func makeSigningKey() throws -> P256.Signing.PrivateKey {
		do {
			return try P256.Signing.PrivateKey(pemRepresentation: Self.normalizedPEM(from: privateKey))
		} catch {
			throw XcodeCloudArtifactProviderError.invalidPrivateKey
		}
	}
}

private extension AppStoreConnectJWT {
	struct Header: Encodable {
		let alg: String
		let kid: String
		let typ: String
	}

	struct Payload: Encodable {
		let iss: String
		let iat: Int
		let exp: Int
		let aud: String
	}

	/// Rebuilds a PKCS #8 PEM document from the key material.
	///
	/// Pasting the contents of a `.p8` file into a text field often collapses or strips the
	/// line breaks, and people sometimes paste only the Base64 body. Normalizing the input
	/// makes all of those forms acceptable.
	static func normalizedPEM(from rawValue: String) -> String {
		var body = rawValue

		for marker in ["-----BEGIN PRIVATE KEY-----", "-----END PRIVATE KEY-----"] {
			body = body.replacingOccurrences(of: marker, with: "")
		}

		body = body.filter { !$0.isWhitespace }

		var lines: [String] = []
		var lineStart = body.startIndex

		while lineStart < body.endIndex {
			let lineEnd = body.index(lineStart, offsetBy: 64, limitedBy: body.endIndex) ?? body.endIndex
			lines.append(String(body[lineStart..<lineEnd]))
			lineStart = lineEnd
		}

		return (["-----BEGIN PRIVATE KEY-----"] + lines + ["-----END PRIVATE KEY-----"])
			.joined(separator: "\n")
	}
}

private extension Data {
	/// Encodes the data using the unpadded, URL-safe Base64 alphabet that JWT requires.
	func base64URLEncodedString() -> String {
		base64EncodedString()
			.replacingOccurrences(of: "+", with: "-")
			.replacingOccurrences(of: "/", with: "_")
			.replacingOccurrences(of: "=", with: "")
	}
}
