//
//  StatusView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-05.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct StatusView: View {
	@EnvironmentObject private var taskStatusReporter: TaskStatusReporter
	@State private var popoverPresented = false

	var body: some View {
		HStack(alignment: .center, spacing: 6) {
			Text(mainStatusText)
				.sectionHeadingTextStyle()
				.lineLimit(1)
				.truncationMode(.tail)
				.id(mainStatusText)
				.transition(.push(from: .top).animation(.easeInOut))
				.animation(.easeInOut, value: mainStatusText)

			Group {
				if let newestTaskStatus = newestTaskStatus {
					if case let .running(_, progress) = newestTaskStatus.state,
					   case let .determinate(totalUnitCount, pendingUnitCount) = progress {
						MainProgressView(
							strokeContent: .tertiary,
							totalUnitCount: totalUnitCount,
							pendingUnitCount: pendingUnitCount,
							taskCount: taskCount
						)

					} else if !newestTaskStatus.state.isConcluded || taskCount > 1 {
						MainProgressView(strokeContent: .tertiary, taskCount: taskCount)
					}
				}
			}
			.contentShape(Circle())
			.onTapGesture {
				if taskCount > 1 {
					popoverPresented.toggle()
				}
			}
			.popover(isPresented: $popoverPresented) {
				StatusPopover()
			}
		}
	}

	private var newestTaskStatus: TaskStatus? {
		taskStatusReporter.statuses.last
	}

	private var mainStatusText: String {
		guard let newestTaskStatus = newestTaskStatus else {
			return "Ready"
		}

		if newestTaskStatus.state == .done {
			return "Finished \(newestTaskStatus.displayName)"
		}

		return newestTaskStatus.displayName
	}

	private var taskCount: Int {
		taskStatusReporter.statuses.count
	}
}
