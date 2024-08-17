//
//  TaskStatusReporter.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Combine
import Collections
import AppKit

/// Manages task statuses and publishes changes to them.
final class TaskStatusReporter: ObservableObject {
	weak var delegate: TaskStatusReporterDelegate?

	private var cancellables: Set<AnyCancellable> = []

	/// A set of the statuses of all currently active tasks.
	@Published private(set) var statuses: OrderedSet<TaskStatus> = [] {
		didSet {
			updateSubscriptions()
		}
	}

	/// Adds a task status.
	///
	/// When a task reaches a ``TaskState/done`` state, the status is
	/// automatically removed from the list of tasks after a short delay.
	/// - Parameter status: The task status to add.
	@MainActor func add(status: TaskStatus) {
		var cancellable: AnyCancellable?
		cancellable = status.$state
			.sink { [weak self] taskState in
				_ = cancellable

				if taskState == .done {
					self?.remove(status: status, withDelay: true)
					cancellable = nil
				}
			}

		statuses.append(status)
	}

	/// Removes a task status.
	/// - Parameters:
	///   - status: The task status to remove.
	///   - withDelay: Whether to delay removal by a few seconds.
	@MainActor func remove(status: TaskStatus, withDelay: Bool = false) {
		Task {
			if withDelay {
				try await Task.sleep(for: .seconds(2))
			}

			statuses.remove(status)
		}
	}

	/// Removes all failed or done task statuses.
	@MainActor func clearConcluded() {
		let filteredItems = statuses.filter { !$0.state.isConcluded }
		statuses = OrderedSet(filteredItems)
	}

	func notify(message: String) {
		delegate?.taskStatusReporter(didReceiveRequestToShowNotificationWithMessage: message)
	}

	@MainActor func alert(title: String, content: String, style: NSAlert.Style, buttonText: String) {
		let options = AlertOptions(title: title, content: content, style: style, buttonText: buttonText)
		delegate?.taskStatusReporter(didReceiveRequestToShowAlertWithOptions: options)
	}

	private func updateSubscriptions() {
		let newCancellables = statuses.map { taskStatus in
			taskStatus.objectWillChange.sink { [weak self] in
				self?.objectWillChange.send()
			}
		}

		self.cancellables = Set(newCancellables)
	}
}
