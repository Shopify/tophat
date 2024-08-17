//
//  GoogleStorageError.swift
//  GoogleStorageKit
//
//  Created by Lukas Romsicki on 2022-10-31.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation

public enum GoogleStorageError: Error {
	case invalidUrl
	case cannotInvokeGSUtil
}
