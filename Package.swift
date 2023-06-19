// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Halley",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Halley", targets: ["Halley"]),
        .library(name: "HalleyMacro", targets: ["HalleyMacro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
    ],
    targets: [
        .target(name: "Halley", path: "Halley"),
        .testTarget(
            name: "HalleyTests",
            dependencies: ["Halley"],
            path: "Tests",
            resources: [.process("Fixtures")]
        ),
        .target(
            name: "HalleyMacro",
            dependencies: [
                "HalleyMacroPlugin"
            ],
            path: "Macro"
        ),
        .macro(
            name: "HalleyMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
            ],
            path: "MacroPlugin"
        ),
        .testTarget(
            name: "HalleyMacroTests",
            dependencies: [
                "HalleyMacro",
                "HalleyMacroPlugin",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            path: "MacroTests"
        )
    ]
)
