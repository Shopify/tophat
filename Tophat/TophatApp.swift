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
import Sparkle
import TophatServer
import AndroidDeviceKit
import AppleDeviceKit
import FluidMenuBarExtra
import TophatFoundation
import SwiftData

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
	}

	var body: some Scene {
		Settings {
			SettingsView()
				.showDockIconWhenOpen()
				.environment(appDelegate.updateController)
				.environment(appDelegate.extensionHost)
				.environmentObject(appDelegate.deviceManager)
				.environmentObject(appDelegate.utilityPathPreferences)
				.environmentObject(appDelegate.launchAtLoginController)
				.environmentObject(appDelegate.symbolicLinkManager)
		}
		.modelContainer(appDelegate.modelContainer)
	}
}

private final class AppDelegate: NSObject, NSApplicationDelegate {
	// Hope nobody is running a Jedi Academy server...
	@AppStorage("ListenPort") private var listenPort: Int = 29070
	@AppStorage("HasCompletedFirstLaunch") private var hasCompletedFirstLaunch = false

	let modelContainer = try! ModelContainer(
		for: QuickLaunchEntry.self,
		configurations: ModelConfiguration(
			url: .applicationSupportDirectory
				.appending(component: Bundle.main.bundleIdentifier!)
				.appending(component: "Tophat.store")
		)
	)

	private var menuBarExtra: FluidMenuBarExtra?

	private let sparkleUpdaterController = SPUStandardUpdaterController(
		startingUpdater: true,
		updaterDelegate: nil,
		userDriverDelegate: nil
	)

	let extensionHost = ExtensionHost()
	private let server = TophatServer()
	private let urlHandler = URLReader()
	private let remoteControlReceiver = RemoteControlReceiver()

	let deviceManager: DeviceManager
	let utilityPathPreferences: UtilityPathPreferences
	let symbolicLinkManager = TophatCtlSymbolicLinkManager()
	let launchAtLoginController = LaunchAtLoginController()

	let updateController: UpdateController

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

		let artifactDownloader = ArtifactDownloader(
			artifactRetrievalCoordinator: ArtifactRetrievalCoordinator(appExtensionIdentityResolver: extensionHost)
		)

		self.installCoordinator = InstallCoordinator(
			artifactDownloader: artifactDownloader,
			deviceListLoader: deviceManager,
			deviceSelector: deviceSelectionManager,
			taskStatusReporter: taskStatusReporter
		)

		self.utilityPathPreferences = UtilityPathPreferences()

		self.updateController = UpdateController(updater: sparkleUpdaterController.updater)

		self.launchApp = LaunchAppAction(installCoordinator: installCoordinator)
		self.prepareDevice = PrepareDeviceAction(taskStatusReporter: taskStatusReporter)
		self.mirrorDeviceDisplay = MirrorDeviceDisplayAction(taskStatusReporter: taskStatusReporter)
		self.showOnboardingWindow = ShowOnboardingWindowAction(
			symbolicLinkManager: symbolicLinkManager,
			utilityPathPreferences: utilityPathPreferences
		)

		AndroidPathResolver.delegate = self.utilityPathPreferences

		super.init()

		configureEventSubscriptions()

		self.server.delegate = self
		self.remoteControlReceiver.delegate = self
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
				.environment(self.updateController)
				.environment(\.launchApp, self.launchApp)
				.environment(\.prepareDevice, self.prepareDevice)
				.environment(\.mirrorDeviceDisplay, self.mirrorDeviceDisplay)
				.environment(\.showOnboardingWindow, self.showOnboardingWindow)
				.modelContainer(self.modelContainer)
		}

		performFirstLaunchTasks()

		Notifications.requestPermissions()
		extensionHost.discover()
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
		Task { @MainActor in
			// Companion to the showDockIconWhenOpen() modifier to hide the dock icon when all
			// modified windows are closed.
			for await _ in NotificationCenter.default.notifications(named: NSWindow.willCloseNotification).compactMap({ _ in }) {
				guard NSApp.activationPolicy() != .accessory else {
					continue
				}

				let visibleWindows = NSApp.windows.filter { window in
					// _NSOrderOutAnimationProxyWindow appears momentarily while a window is ordering out.
					window.isVisible && !window.className.contains("NSOrderOutAnimationProxyWindow")
				}

				// The application is considered "inactive" when only the NSStatusBarWindow, and the window
				// that is about to be closed are visible.
				if visibleWindows.count < 2 {
					NSApp.setActivationPolicy(.accessory)
				}
			}
		}
	}

	private func handle(urls: [URL]) {
		do {
			for url in urls {
				let urlReaderResult = try urlHandler.read(url: url)

				Task {
					switch urlReaderResult {
						case .localFile(let url):
							await launchApp(artifactURL: url)
						case .install(let recipes):
							await launchApp(recipes: recipes)
					}
				}
			}
		} catch let error {
			if let error = error as? URLReaderError {
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

// MARK: - RemoteControlReceiverDelegate

extension AppDelegate: RemoteControlReceiverDelegate {
	func remoteControlReceiver(didReceiveRequestToAddQuickLaunchEntry quickLaunchEntry: QuickLaunchEntry) {
		let context = ModelContext(modelContainer)

		let existingID = quickLaunchEntry.id
		let existingEntryFetchDescriptor = FetchDescriptor<QuickLaunchEntry>(
			predicate: #Predicate { $0.id == existingID }
		)

		do {
			if let existingEntry = try context.fetch(existingEntryFetchDescriptor).first {
				existingEntry.name = quickLaunchEntry.name
				existingEntry.recipes = quickLaunchEntry.recipes
			} else {
				var fetchDescriptor = FetchDescriptor<QuickLaunchEntry>(
					sortBy: [SortDescriptor(\.order, order: .reverse)]
				)
				fetchDescriptor.fetchLimit = 1

				let existingEntries = try? context.fetch(fetchDescriptor)
				let lastOrder = existingEntries?.first?.order ?? 0
				quickLaunchEntry.order = lastOrder + 1

				context.insert(quickLaunchEntry)
				try context.save()
			}
		} catch {
			log.error("Failed to update Quick Launch entry!")
		}
	}

	func remoteControlReceiver(didReceiveRequestToRemoveQuickLaunchEntryWithIdentifier quickLaunchEntryIdentifier: QuickLaunchEntry.ID) {
		let context = ModelContext(modelContainer)

		do {
			try context.delete(
				model: QuickLaunchEntry.self,
				where: #Predicate { $0.id == quickLaunchEntryIdentifier }
			)
		} catch {
			log.error("Failed to delete Quick Launch entry.")
		}
	}

	func remoteControlReceiver(didOpenURL url: URL, launchArguments: [String]) async {
		await launchApp(artifactURL: url, launchArguments: launchArguments)
	}

	func remoteControlReceiver(didReceiveRequestToLaunchApplicationWithRecipes recipes: [InstallRecipe]) async {
		await launchApp(recipes: recipes)
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
