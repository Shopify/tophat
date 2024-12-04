//
//  TaskState.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// The state of a running task.
enum TaskState: Sendable {
	/// The task is preparing to run.
	case preparing
	/// The task is waiting for a precondition.
	case waiting(reason: WaitingReason)
	/// The task is currently running.
	case running(message: String, progress: TaskProgress = .indeterminate)
	/// The task is performing finishing or cleanup operations.
	case finishing
	/// The task is fully complete and will not perform any further operations.
	case done

	enum WaitingReason: Sendable {
		/// The task is waiting because a device is locked.
		case deviceIsLocked
	}
}

extension TaskState {
	/// Whether the state should be considered as being concluded.
	var isConcluded: Bool {
		return self == .done
	}
}

// MARK: - Equatable

extension TaskState: Equatable {}
