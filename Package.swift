// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Halley",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Halley", targets: ["Halley"]),
        .library(name: "HalleyMacro", targets: ["HalleyMacro"]),
        .executable(name: "HalleyMacroClient", targets: ["HalleyMacroClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", "509.1.0"..<"511.0.0"),
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
                "HalleyMacroPlugin",
                "Halley"
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
        .executableTarget(
            name: "HalleyMacroClient", 
            dependencies: ["HalleyMacro"],
            path: "MacroClient"
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
