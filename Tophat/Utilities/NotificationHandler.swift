//
//  NotificationHandler.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-27.
//  Copyright © 2023 Shopify. All rights reserved.
//

import Foundation
import Combine
import TophatFoundation
import TophatKit

protocol NotificationHandlerDelegate: AnyObject {
	func notificationHandler(didReceiveRequestToAddPinnedApplication pinnedApplication: PinnedApplication)
	func notificationHandler(didReceiveRequestToRemovePinnedApplicationWithIdentifier pinnedApplicationIdentifier: PinnedApplication.ID)
}

final class NotificationHandler {
	weak var delegate: NotificationHandlerDelegate?

	let onLaunchArtifactSet = PassthroughSubject<(ArtifactSet, Platform, [String]), Never>()
	let onLaunchArtifactURL = PassthroughSubject<(URL, [String]), Never>()
	let onLaunchArtifactProviderURL = PassthroughSubject<(URL, [String]), Never>()

	private let notifier = TophatInterProcessNotifier()
	private var cancellables: Set<AnyCancellable> = []

	init() {
		notifier
			.publisher(for: TophatInstallHintedNotification.self)
			.map { payload in
				(ArtifactSet(artifacts: payload.artifacts), payload.platform, payload.launchArguments)
			}
			.sink { [weak self] result in
				self?.onLaunchArtifactSet.send(result)
			}
			.store(in: &cancellables)

		notifier
			.publisher(for: TophatInstallGenericNotification.self)
			.sink { [weak self] payload in
				if payload.isAPI {
					self?.onLaunchArtifactProviderURL.send((payload.url, payload.launchArguments))
				} else {
					self?.onLaunchArtifactURL.send((payload.url, payload.launchArguments))
				}
			}
			.store(in: &cancellables)

		notifier
			.publisher(for: TophatAddPinnedApplicationNotification.self)
			.sink { [weak self] payload in
				let pinnedApplication = PinnedApplication(
					id: payload.id,
					name: payload.name,
					platform: payload.platform,
					artifacts: payload.artifacts,
					artifactProviderURL: payload.artifactProviderURL
				)

				self?.delegate?.notificationHandler(didReceiveRequestToAddPinnedApplication: pinnedApplication)
			}
			.store(in: &cancellables)

		notifier
			.publisher(for: TophatRemovePinnedApplicationNotification.self)
			.sink { [weak self] payload in
				self?.delegate?.notificationHandler(didReceiveRequestToRemovePinnedApplicationWithIdentifier: payload.id)
			}
			.store(in: &cancellables)
	}
}

private extension TophatInstallHintedNotification.Payload {
	var artifacts: [Artifact] {
		convertToArtifacts(virtualURL: virtualURL, physicalURL: physicalURL, universalURL: universalURL)
	}
}

private extension TophatAddPinnedApplicationNotification.Payload {
	var artifacts: [Artifact] {
		convertToArtifacts(virtualURL: virtualURL, physicalURL: physicalURL, universalURL: universalURL)
	}
}

private func convertToArtifacts(virtualURL: URL?, physicalURL: URL?, universalURL: URL?) -> [Artifact] {
	var artifacts: [Artifact] = []

	if let virtualURL = virtualURL {
		artifacts.append(.init(url: virtualURL, targets: [.virtual]))
	}

	if let physicalURL = physicalURL {
		artifacts.append(.init(url: physicalURL, targets: [.physical]))
	}

	if let universalURL = universalURL {
		artifacts.append(.init(url: universalURL, targets: [.virtual, .physical]))
	}

	return artifacts
}
