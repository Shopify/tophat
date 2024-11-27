//
//  InstallSession.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-11-26.
//  Copyright © 2024 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation

/// An install session represents a short period of time during which the user indends to install
/// applications.  An install session receives requests to launch applications and processes them.
///
/// While an install session is active, it can continuously receive requests to install applications. During
/// this period, downloads are cached so that repeated requests do not redownload the same resources
/// Install sessions are intended to be destroyed and recreated each time Tophat becomes idle, so that
/// future requests are not subject to caching and latest artifacts can be downloaded.
actor InstallSession {
	private let applicationDownloader: ApplicationDownloading
	private let ticketMachine: InstallationTicketMachine
	private let taskStatusReporter: TaskStatusReporter

	private var activeRequestsCount: Int = 0 {
		didSet {
			if activeRequestsCount != oldValue {
				isIdleUpdatesContinuation.yield(activeRequestsCount == 0)
			}
		}
	}

	var isIdle: Bool {
		activeRequestsCount == 0
	}

	let isIdleUpdates: AsyncStream<Bool>
	private let isIdleUpdatesContinuation: AsyncStream<Bool>.Continuation

	init(
		artifactDownloader: ArtifactDownloader,
		deviceSelector: DeviceSelecting,
		taskStatusReporter: TaskStatusReporter
	) {
		self.applicationDownloader = CachingApplicationDownloader(
			artifactDownloader: artifactDownloader,
			artifactUnpacker: ArtifactUnpacker(),
			taskStatusReporter: taskStatusReporter
		)

		self.ticketMachine = InstallationTicketMachine(
			deviceSelector: deviceSelector,
			applicationDownloader: applicationDownloader
		)

		self.taskStatusReporter = taskStatusReporter

		(self.isIdleUpdates, self.isIdleUpdatesContinuation) = AsyncStream.makeStream()
	}

	deinit {
		Task { [applicationDownloader] in
			log.info("[InstallSession] Cleaning up resources.")
			try? await applicationDownloader.cleanUp()
		}
	}

	/// Downloads, installs, and launches applications on selected devices.
	///
	/// If an appropriate device is found for a recipe in advance, the device is booted in parallel
	/// with the download process to improve completion time.
	///
	/// - Parameters:
	///   - recipes: A collection of recipes for retrieving builds.
	///   - context: Additional metadata for the operation.
	func install(recipes: [InstallRecipe], context: OperationContext? = nil) async throws {
		activeRequestsCount += 1
		defer { activeRequestsCount -= 1 }

		try await withThrowingTaskGroup(of: Void.self) { group in
			for try await ticket in ticketMachine.process(recipes: recipes) {
				group.addTask { [weak self] in
					try await self?.install(ticket: ticket, context: context)
				}
			}

			try await group.waitForAll()
		}
	}

	private func install(ticket: InstallationTicketMachine.Ticket, context: OperationContext?) async throws {
		let device = ticket.device
		let prepareDevice = PrepareDeviceTask(taskStatusReporter: taskStatusReporter)

		async let futureApplication = {
			switch ticket.artifactLocation {
				case .remote(let source):
					try await applicationDownloader.download(from: source, context: context)
				case .local(let application):
					application
			}
		}()

		async let futurePrepareDeviceResult = prepareDevice(device: device)

		let (application, prepareDeviceResult) = await (
			try futureApplication,
			try futurePrepareDeviceResult
		)

		if !prepareDeviceResult.deviceWasColdBooted {
			// If the device wasn't cold booted, bring it to the foreground later in the process.
			log.info("Bringing device with identifier \(device.id) to foreground")

			// This is a non-critical feature, it is allowed to fail in case the
			// user hasn't accepted permissions.
			try? device.focus()
		}

		let installApplication = InstallApplicationTask(taskStatusReporter: taskStatusReporter, context: context)

		try await installApplication(
			application: application,
			device: device,
			launchArguments: ticket.launchArguments
		)
	}
}
