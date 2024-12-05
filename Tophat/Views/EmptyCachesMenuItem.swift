//
//  EmptyCachesMenuItem.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2024-12-04.
//  Copyright © 2024 Shopify. All rights reserved.
//

import SwiftUI
import TophatFoundation

struct EmptyCachesMenuItem: View {
	private let cacheURL: URL = .cachesDirectory.appending(path: Bundle.main.bundleIdentifier!)

	@EnvironmentObject private var taskStatusReporter: TaskStatusReporter
	@State private var bytes: Int64 = 0

	var body: some View {
		Button {
			Task {
				try? FileManager.default.removeItem(at: cacheURL)
				await calculateSize()
			}
		} label: {
			HStack {
				Text("Empty Caches")
				Spacer()
				Text("Size: \(bytes, format: .byteCount(style: .file, spellsOutZero: true))")
					.foregroundStyle(.tertiary)
			}
		}
		.buttonStyle(.menuItem(blinks: true, disabled: !taskStatusReporter.statuses.isEmpty || bytes == 0))
		.task {
			await calculateSize()
		}
	}

	private func calculateSize() async {
		do {
			bytes = try await cacheURL.calculateSizeInBytes()
		} catch {
			log.error("Failed to calculate the size of the cache directory: \(error)")
		}
	}
}
