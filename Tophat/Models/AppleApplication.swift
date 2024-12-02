//
//  AppleApplication.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-21.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import AppleDeviceKit

struct AppleApplication: Application {
	private let bundleURL: URL
	private let appStorePackageURL: URL?

	init(bundleURL: URL, appStorePackageURL: URL? = nil) {
		self.bundleURL = bundleURL
		self.appStorePackageURL = appStorePackageURL
	}

	var url: URL {
		bundleURL
	}

	var name: String? {
		guard let displayName = bundle?.infoDictionary?["CFBundleDisplayName"] as? String else {
			return nil
		}

		return displayName
	}

	var icon: URL? {
		guard
			let icons = bundle?.infoDictionary?["CFBundleIcons"] as? [String: Any],
			let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
			let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
			let lastIcon = iconFiles.last,
			let imageURL = bundle?.url(forResource: "\(lastIcon)@2x", withExtension: "png")
		else {
			return nil
		}

		return imageURL
	}

	var targets: Set<DeviceType> {
		guard let platformNames = bundle?.infoDictionary?["CFBundleSupportedPlatforms"] as? [String] else {
			return []
		}

		var set: Set<DeviceType> = []

		// Only iOS supported, for now.
		platformNames.forEach { platformName in
			switch platformName {
				case "iPhoneOS":
					set.insert(.device)
				case "iPhoneSimulator":
					set.insert(.simulator)
				default:
					break
			}
		}

		return set
	}

	var platform: Platform {
		// Only iOS supported, for now.
		.iOS
	}

	var bundleIdentifier: String {
		get throws {
			guard let bundleIdentifier = bundle?.bundleIdentifier else {
				throw ApplicationError.failedToReadBundleIdentifier
			}

			return bundleIdentifier
		}
	}

	func validateEligibility(for device: Device) throws {
		guard platform == device.runtime.platform, targets.contains(device.type) else {
			throw ApplicationError.incompatible(application: self, device: device)
		}

		if device.type == .simulator {
			// Remaining checks are not needed for simulator devices.
			return
		}

		if !signedWithDevelopmentCertificate {
			throw ApplicationError.applicationNotSigned
		}

		guard let provisioningProfile = bundle?.embeddedProvisioningProfile else {
			throw ApplicationError.missingProvisioningProfile
		}

		let deviceIsProvisioned = provisioningProfile.provisionsAllDevices
			?? provisioningProfile.provisionedDevices?.contains(device.id)
			?? false

		if !deviceIsProvisioned {
			throw ApplicationError.deviceNotProvisioned
		}
	}
}

extension AppleApplication: Deletable {
	nonisolated func delete() async throws {
		let fileManager = FileManager.default

		try fileManager.removeItem(at: bundleURL)

		if let appStorePackageURL {
			try fileManager.removeItem(at: appStorePackageURL)
		}
	}
}

private extension AppleApplication {
	var bundle: Bundle? {
		Bundle(url: bundleURL)
	}

	var entitlements: [String: Any] {
		var staticCode: SecStaticCode?
		var signingInformation: CFDictionary?

		guard
			SecStaticCodeCreateWithPath(bundleURL as CFURL, [], &staticCode) == errSecSuccess,
			let staticCode = staticCode,
			SecCodeCopySigningInformation(staticCode, .signingInformation, &signingInformation) == errSecSuccess,
			let signingInformation = signingInformation as? [String: Any],
			let entitlements = signingInformation[kSecCodeInfoEntitlementsDict as String] as? [String: Any]
		else {
			return [:]
		}

		return entitlements
	}

	var signedWithDevelopmentCertificate: Bool {
		var staticCode: SecStaticCode?
		var requirement: SecRequirement?

		// Apple Worldwide Developer Relations (Apple Development) certificate OID: 1.2.840.113635.100.6.2.1
		// See: https://images.apple.com/certificateauthority/pdf/Apple_WWDR_CPS_v1.27.pdf
		// Code signed with this certificate can run on devices provided that the device has the associated
		// provisioning profile installed.
		let requirementString = "anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.1]"

		let validityCheckFlags: SecCSFlags = [
			.basicValidateOnly,
			.considerExpiration
		]

		if
			SecRequirementCreateWithString(requirementString as CFString, [], &requirement) == errSecSuccess,
			let requirement = requirement,
			SecStaticCodeCreateWithPath(bundleURL as CFURL, [], &staticCode) == errSecSuccess,
			let staticCode = staticCode,
			SecStaticCodeCheckValidity(staticCode, validityCheckFlags, requirement) == errSecSuccess
		{
			return true
		}

		return false
	}
}

private extension SecCSFlags {
	static let signingInformation = Self(rawValue: kSecCSSigningInformation)
	static let basicValidateOnly = Self(rawValue: kSecCSBasicValidateOnly)
}

private extension Bundle {
	var embeddedProvisioningProfile: ProvisioningProfile? {
		guard let profileURL = url(forResource: "embedded", withExtension: "mobileprovision") else {
			return nil
		}

		return ProvisioningProfile(url: profileURL)
	}
}
