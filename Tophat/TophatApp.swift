//
//  TophatApp.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-26.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI
import Combine
import Logging
import LoggingOSLog
import ServiceManagement
import UserNotifications
import TophatServer
import AndroidDeviceKit
import AppleDeviceKit
import GoogleStorageKit
import FluidMenuBarExtra
import TophatFoundation

let log = Logger(label: Bundle.main.bundleIdentifier!)

@main
struct TophatApp: App {
	// Weak delegate rule doesn't apply in SwiftUI structures.
	// swiftlint:disable weak_delegate
	@NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

	init() {
		LoggingSystem.bootstrap(LoggingOSLog.init)

		log.info("Launching Tophat application")

		AndroidDeviceKit.log = log
		AppleDeviceKit.log = log
		GoogleStorageKit.log = log
	}

	var body: some Scene {
		Settings {
			SettingsView()
				.environmentObject(appDelegate.deviceManager)
				.environmentObject(appDelegate.pinnedApplicationState)
				.environmentObject(appDelegate.utilityPathPreferences)
				.environmentObject(appDelegate.launchAtLoginController)
				.environmentObject(appDelegate.symbolicLinkManager)
		}
	}
}

private final class AppDelegate: NSObject, NSApplicationDelegate {
	// Hope nobody is running a Jedi Academy server...
	@AppStorage("ListenPort") private var listenPort: Int = 29070
	@AppStorage("HasCompletedFirstLaunch") private var hasCompletedFirstLaunch = false

	private var menuBarExtra: FluidMenuBarExtra?

	private let server = TophatServer()
	private let urlHandler = URLHandler()
	private let notificationHandler = NotificationHandler()

	let deviceManager: DeviceManager
	let pinnedApplicationState: PinnedApplicationState
	let utilityPathPreferences: UtilityPathPreferences
	let symbolicLinkManager = TophatCtlSymbolicLinkManager()
	let launchAtLoginController = LaunchAtLoginController()

	private let deviceSelectionManager: DeviceSelectionManager
	private let taskStatusReporter: TaskStatusReporter
	private let installCoordinator: InstallCoordinator

	private let launchApp: LaunchAppAction
	private let prepareDevice: PrepareDeviceAction
	private let mirrorDeviceDisplay: MirrorDeviceDisplayAction
	private let showOnboardingWindow: ShowOnboardingWindowAction

	private var onboardingWindow: NSWindow?

	private var cancellables = Set<AnyCancellable>()

	override init() {
		self.deviceManager = DeviceManager(sources: [
			AppleDevices.self,
			AndroidDevices.self
		])

		self.deviceSelectionManager = DeviceSelectionManager(deviceManager: deviceManager)
		self.taskStatusReporter = TaskStatusReporter()
		self.pinnedApplicationState = PinnedApplicationState()

		self.installCoordinator = InstallCoordinator(
			deviceManager: deviceManager,
			deviceSelectionManager: deviceSelectionManager,
			pinnedApplicationState: pinnedApplicationState,
			taskStatusReporter: taskStatusReporter
		)

		self.utilityPathPreferences = UtilityPathPreferences()
		self.launchApp = LaunchAppAction(installCoordinator: installCoordinator)
		self.prepareDevice = PrepareDeviceAction(taskStatusReporter: taskStatusReporter)
		self.mirrorDeviceDisplay = MirrorDeviceDisplayAction(taskStatusReporter: taskStatusReporter)
		self.showOnboardingWindow = ShowOnboardingWindowAction(
			symbolicLinkManager: symbolicLinkManager,
			utilityPathPreferences: utilityPathPreferences
		)

		AndroidPathResolver.delegate = self.utilityPathPreferences
		GoogleStoragePathResolver.delegate = self.utilityPathPreferences

		super.init()

		configureEventSubscriptions()

		self.server.delegate = self
		self.installCoordinator.delegate = self
		self.notificationHandler.delegate = self
		self.taskStatusReporter.delegate = self
	}

	func applicationWillFinishLaunching(_ notification: Notification) {
		UNUserNotificationCenter.current().delegate = self
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		do {
			log.info("Starting Tophat server on port \(listenPort)")
			try server.start(on: listenPort)

		} catch {
			log.error("Failed to start Tophat server: \(error)")
			Notifications.alert(
				title: "Unable to start Tophat",
				content: "An error occurred while starting Tophat. Make sure no other instances of Tophat are running and try again.",
				style: .critical,
				buttonText: "Quit"
			)

			NSApplication.shared.terminate(nil)
		}

		Task {
			await self.deviceManager.loadDevices()
		}

		menuBarExtra = FluidMenuBarExtra(title: "Tophat", image: "tophat.fill") {
			MainMenu()
				.modifier(ShowingAlternateItemsViewModifier())
				.modifier(ShowingAdvancedOptions())
				.environmentObject(self.deviceManager)
				.environmentObject(self.deviceSelectionManager)
				.environmentObject(self.taskStatusReporter)
				.environmentObject(self.pinnedApplicationState)
				.environment(\.launchApp, self.launchApp)
				.environment(\.prepareDevice, self.prepareDevice)
				.environment(\.mirrorDeviceDisplay, self.mirrorDeviceDisplay)
				.environment(\.showOnboardingWindow, self.showOnboardingWindow)
		}

		performFirstLaunchTasks()

		Notifications.requestPermissions()
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		handle(urls: urls)
	}

	private func performFirstLaunchTasks() {
		guard !hasCompletedFirstLaunch else {
			return
		}

		showOnboardingWindow()

		#if !DEBUG
		// Configure the application to launch at login.
		if !hasCompletedFirstLaunch {
			launchAtLoginController.isEnabled = true
		}
		#endif

		hasCompletedFirstLaunch = true
	}

	private func configureEventSubscriptions() {
		Publishers.MergeMany(
			self.urlHandler.onLaunchArtifactURL,
			self.notificationHandler.onLaunchArtifactURL
		)
		.sink { [weak self] (url, launchArguments) in
			Task.detached(priority: .userInitiated) { [weak self] in
				await self?.launchApp(artifactURL: url, context: LaunchContext(arguments: launchArguments))
			}
		}
		.store(in: &cancellables)

		Publishers.MergeMany(
			self.urlHandler.onLaunchArtifactSet,
			self.notificationHandler.onLaunchArtifactSet
		)
		.sink { [weak self] (artifactSet, platform, launchArguments) in
			Task.detached(priority: .userInitiated) { [weak self] in
				await self?.launchApp(artifactSet: artifactSet, on: platform, context: LaunchContext(arguments: launchArguments))
			}
		}
		.store(in: &cancellables)
	}

	private func handle(urls: [URL]) {
		do {
			try urlHandler.handle(urls: urls)
		} catch let error {
			if let error = error as? URLHandlerError {
				switch error {
					case .malformedURL(let url):
						log.error("Attempting to handle URL but it was malformed: \(url.absoluteString)")
					case .unsupportedURL(let url):
						log.error("Attempting to unsupported URL: \(url.absoluteString)")
				}
			} else {
				log.error("Failed to handle URL. Error: \(error)")
			}
		}
	}
}

// MARK: - TophatServerDelegate

extension AppDelegate: TophatServerDelegate {
	func server(didOpenURL url: URL) {
		handle(urls: [url])
	}
}

// MARK: - InstallCoordinatorDelegate

extension AppDelegate: InstallCoordinatorDelegate {
	func installCoordinator(didSuccessfullyInstallAppForPlatform platform: Platform) {
		DistributedNotificationCenter.default().postNotificationName(
			.init("TophatInstallSucceeded"),
			object: nil,
			userInfo: ["platform": String(describing: platform).lowercased()],
			deliverImmediately: true
		)
	}

	func installCoordinator(didFailToInstallAppForPlatform platform: Platform?) {
		DistributedNotificationCenter.default().postNotificationName(
			.init("TophatInstallFailed"),
			object: nil,
			userInfo: ["platform": String(describing: platform).lowercased()],
			deliverImmediately: true
		)
	}

	func installCoordinator(didPromptToAllowUntrustedHost host: String) async -> HostTrustResult {
		await TrustedHostAlert().requestTrust(for: host)
	}
}

// MARK: - NotificationHandlerDelegate

extension AppDelegate: NotificationHandlerDelegate {
	func notificationHandler(didReceiveRequestToAddPinnedApplication pinnedApplication: PinnedApplication) {
		if let existingIndex = pinnedApplicationState.pinnedApplications.firstIndex(where: { $0.id == pinnedApplication.id }) {
			let existingItem = pinnedApplicationState.pinnedApplications[existingIndex]

			var newPinnedApplication = pinnedApplication
			newPinnedApplication.icon = existingItem.icon
			pinnedApplicationState.pinnedApplications[existingIndex] = newPinnedApplication

		} else {
			pinnedApplicationState.pinnedApplications.append(pinnedApplication)
		}
	}

	func notificationHandler(didReceiveRequestToRemovePinnedApplicationWithIdentifier pinnedApplicationIdentifier: PinnedApplication.ID) {
		pinnedApplicationState.pinnedApplications.removeAll { $0.id == pinnedApplicationIdentifier }
	}
}

// MARK: - TaskStatusReporterDelegate

extension AppDelegate: TaskStatusReporterDelegate {
	func taskStatusReporter(didReceiveRequestToShowNotificationWithMessage message: String) {
		Notifications.notify(message: message)
	}

	@MainActor func taskStatusReporter(didReceiveRequestToShowAlertWithOptions options: AlertOptions) {
		Notifications.alert(
			title: options.title,
			content: options.content,
			style: options.style,
			buttonText: options.buttonText
		)
	}
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.badge, .banner, .sound])
	}
}
