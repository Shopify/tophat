//
//  StatusPopover.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-05.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct StatusPopover: View {
	@EnvironmentObject private var taskStatusReporter: TaskStatusReporter

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			ForEach(taskStatusReporter.statuses) { status in
				HStack(alignment: .center, spacing: 10) {
					if case let .running(_, progress) = status.state,
					   case let .determinate(totalUnitCount, pendingUnitCount) = progress {
						MainProgressView(
							strokeContent: .blue,
							totalUnitCount: totalUnitCount,
							pendingUnitCount: pendingUnitCount
						)
					} else {
						MainProgressView(strokeContent: .blue)
					}

					VStack(alignment: .leading, spacing: 2) {
						Text(status.displayName)
							.font(.body)
							.foregroundColor(.primary)

						Text(String(describing: status))
							.font(.caption)
							.foregroundColor(.primary)
							.opacity(0.7)
					}
				}
			}
		}
		.padding()
	}
}

extension TaskStatus: CustomStringConvertible {
	var description: String {
		switch state {
			case .preparing:
				return "Preparing"
			case .waiting:
				return "Waiting"
			case .running(let message, _):
				return message
			case .finishing:
				return "Cleaning up"
			case .done:
				return "Done"
		}
	}
}
