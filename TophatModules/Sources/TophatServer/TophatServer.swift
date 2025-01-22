//
//  TophatServer.swift
//  TophatServer
//
//  Created by Lukas Romsicki on 2022-10-19.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import Swifter
import Combine

/// An HTTP server that provides an interface for triggering artifact installation from a web browser.
public final class TophatServer {
	public weak var delegate: TophatServerDelegate?

	private let server = HttpServer()

	private var baseURL: URL? {
		guard let port = try? server.port() else {
			return nil
		}

		var components = URLComponents()
		components.scheme = "http"
		components.host = "localhost"
		components.port = port

		return components.url
	}

	public init() {
		configureRoutes()
		configureServer()
	}

	/// Starts the server in a background task.
	public func start(on port: Int) throws {
		try server.start(in_port_t(port), forceIPv4: true, priority: .background)
	}

	private func configureServer() {
		// Loopback only to skip Firewall permission dialog. Only local connections needed.
		server.listenAddressIPv4 = "127.0.0.1"
	}

	private func configureRoutes() {
		server["/install/:platform"] = handle(request:)
		server["/install"] = handle(request:)
	}

	private func handle(request: HttpRequest) -> HttpResponse {
		guard let installTemplate = loadTemplate(named: "install") else {
			return .internalServerError
		}

		let queryItems = request.queryParams.map { URLQueryItem(name: $0, value: $1) }

		guard let baseURL = baseURL else {
			return .internalServerError
		}

		let encodedURL = baseURL.appending(path: request.path).appending(queryItems: queryItems)
		guard let decodedString = encodedURL.absoluteString.removingPercentEncoding,
              let url = URL(string: decodedString) else {
			return .internalServerError
		}

		delegate?.server(didOpenURL: url)

		return .ok(.html(installTemplate))
	}

	private func loadTemplate(named name: String) -> String? {
		guard let filePath = Bundle.module.path(forResource: name, ofType: "html") else {
			return nil
		}

		return try? String(contentsOfFile: filePath)
	}
}

private extension Array where Element == (String, String) {
	subscript(_ keyToFind: String) -> String? {
		first { key, value in
			key == keyToFind
		}?.1
	}
}
