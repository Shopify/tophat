//
//  MainProgressView.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-05.
//  Copyright © 2023 Shopify. All rights reserved.
//

import SwiftUI

struct MainProgressView<StrokeContent: ShapeStyle>: View {
	private let strokeContent: StrokeContent
	private let totalUnitCount: Double?
	private let pendingUnitCount: Double?
	private let taskCount: Int?

	init(strokeContent: StrokeContent, totalUnitCount: Double, pendingUnitCount: Double, taskCount: Int? = nil) {
		self.strokeContent = strokeContent
		self.totalUnitCount = totalUnitCount
		self.pendingUnitCount = pendingUnitCount
		self.taskCount = taskCount
	}

	init(strokeContent: StrokeContent, taskCount: Int? = nil) {
		self.strokeContent = strokeContent
		self.totalUnitCount = nil
		self.pendingUnitCount = nil
		self.taskCount = taskCount
	}

	var body: some View {
		ProgressView(value: pendingUnitCount, total: totalUnitCount ?? 1) {
			if let taskCount = taskCount, taskCount > 1 {
				Text(String(taskCount))
			}
		}
		.progressViewStyle(TophatProgressViewStyle(strokeContent: strokeContent))
		.animation(.default, value: [totalUnitCount, pendingUnitCount])
	}
}
