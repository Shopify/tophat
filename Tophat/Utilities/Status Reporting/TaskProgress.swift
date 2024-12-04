//
//  TaskProgress.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-20.
//  Copyright © 2022 Shopify. All rights reserved.
//

/// The progress of a running task.
enum TaskProgress: Sendable {
	/// The task does not report progress.
	case indeterminate
	/// The task has measurable progress.
	case determinate(totalUnitCount: Double, pendingUnitCount: Double)
}

// MARK: - Equatable

extension TaskProgress: Equatable {}
