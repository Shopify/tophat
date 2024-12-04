//
//  TaskStatus.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

/// The status of one running task.
///
/// A `TaskStatus` can be updated over time in the context of the task it
/// represents to notify subscribers that the status of the task has changed.
///
/// You must tell the application about the task status for it to be reported in the
/// UI. To do this, the task must be registered in the application's task status
/// reporter using ``TaskStatusReporter/register(taskStatus:)``.
@MainActor final class TaskStatus: Identifiable, ObservableObject {
	typealias ID = String

	let id: ID
	let displayName: String
	let metadata: TaskStatusMetadata?

	@Published private(set) var state: TaskState

	init(displayName: String, initialState state: TaskState, metadata: TaskStatusMetadata? = nil) {
		self.id = UUID().uuidString
		self.displayName = displayName
		self.state = state
		self.metadata = metadata
	}

	/// Updates the state of the task.
	/// - Parameter state: The new state of the task.
	func update(state: TaskState) {
		self.state = state
	}

	/// Convenience for setting the state of the task to ``TaskState/done``.
	func markAsDone() {
		update(state: .done)
	}
}

// MARK: - Hashable

extension TaskStatus: Hashable {
	nonisolated static func == (lhs: TaskStatus, rhs: TaskStatus) -> Bool {
		lhs.id == rhs.id
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
