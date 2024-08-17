//
//  TaskStatusReporterDelegate.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2023-01-25.
//  Copyright © 2023 Shopify. All rights reserved.
//

public protocol TaskStatusReporterDelegate: AnyObject {
	func taskStatusReporter(didReceiveRequestToShowNotificationWithMessage message: String)
	func taskStatusReporter(didReceiveRequestToShowAlertWithOptions options: AlertOptions)
}
