// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "TophatModules",
	platforms: [
		.macOS(.v14)
	],
	products: [
		.library(name: "AndroidDeviceKit", targets: ["AndroidDeviceKit"]),
		.library(name: "AppleDeviceKit", targets: ["AppleDeviceKit"]),
		.library(name: "ShellKit", targets: ["ShellKit"]),
		.library(name: "TophatControlServices", targets: ["TophatControlServices"]),
		.library(name: "TophatFoundation", targets: ["TophatFoundation"]),
		.library(name: "TophatServer", targets: ["TophatServer"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", exact: "1.4.4"),
		.package(url: "https://github.com/httpswift/swifter.git", exact: "1.5.0"),
	],
	targets: [
		.target(
			name: "AndroidDeviceKit",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				.target(name: "TophatFoundation"),
				.target(name: "ShellKit")
			]
		),
		.target(
			name: "AppleDeviceKit",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				.target(name: "TophatFoundation"),
				.target(name: "ShellKit")
			]
		),
		.target(
			name: "ShellKit",
			dependencies: [
				.product(name: "Logging", package: "swift-log")
			]
		),
		.target(
			name: "TophatControlServices",
			dependencies: [
				.target(name: "TophatFoundation"),
				.product(name: "Logging", package: "swift-log")
			]
		),
		.target(name: "TophatFoundation"),
		.target(
			name: "TophatServer",
			dependencies: [
				.product(name: "Swifter", package: "swifter"),
			],
			resources: [
				.process("Resources")
			]
		)
	]
)
