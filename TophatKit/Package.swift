// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TophatKit",
	platforms: [
		.macOS(.v14)
	],
    products: [
        .library(
            name: "TophatKit",
            targets: ["TophatKit"]
		    ),
    ],
    targets: [
        .target(name: "TophatKit")
    ]
)
