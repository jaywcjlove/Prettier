// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Prettier",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Prettier",
            targets: ["Prettier"]
        ),
    ],
    targets: [
        .target(
            name: "Prettier",
            resources: [
                .copy("Resources/prettier.bundle.min.js")
            ]
        ),
        .testTarget(
            name: "PrettierTests",
            dependencies: ["Prettier"]
        ),
    ]
)
