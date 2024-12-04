//
//  TaskStatusReporterDelegate.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

public protocol TaskStatusReporterDelegate: AnyObject {
	@MainActor func taskStatusReporter(didReceiveRequestToShowNotificationWithMessage message: String)
}
