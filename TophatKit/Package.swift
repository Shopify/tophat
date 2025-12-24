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
        .library(
            name: "SecureStorage",
            targets: [
                "SecureStorage"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/auth0/SimpleKeychain.git", .upToNextMajor(from: "1.2.0"))
    ],
    targets: [
        .target(name: "TophatKit"),
        .target(
            name: "SecureStorage",
            dependencies: [
                .product(name: "SimpleKeychain", package: "SimpleKeychain")
            ]
        )
    ]
)
