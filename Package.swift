// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Halley",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Halley", targets: ["Halley"]),
    ],
    targets: [
        .target(
            name: "Halley",
            path: "Halley"
        ),
        .testTarget(
            name: "HalleyTests",
            dependencies: ["Halley"],
            path: "Tests",
            resources: [.process("Fixtures")]
        )
    ]
)
