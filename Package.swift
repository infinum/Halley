// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Halley",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Halley",
            targets: ["Halley"]),
    ],
    dependencies: [
        .package(name: "CombineExt", url: "https://github.com/CombineCommunity/CombineExt.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "URITemplate", url: "https://github.com/kylef/URITemplate.swift.git", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "Halley",
            dependencies: ["CombineExt", "URITemplate"],
            path: "Halley/Classes",
            exclude: [
                "Core/Halley"
            ]),
        .testTarget(
            name: "HalleyTests",
            dependencies: ["Halley"],
            path: "Example/Tests",
            exclude: [
                "Info.plist"
            ])
    ]
)
