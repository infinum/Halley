import SwiftSyntax
import SwiftSyntaxMacrosGenericTestSupport
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import Testing
@testable import HalleyMacro
@testable import HalleyMacroPlugin

final class CodingKeysMacroTests {
    let macros: [String: Macro.Type] = [
        "HalleyModel": HalleyModelMacro.self,
        "HalleyCodingKey": HalleyCodingKeyMacro.self
    ]

    @Test("Internal struct")
    func testInternalStruct() throws {
        assertMacroExpansionWithSwiftTesting(
            """
            protocol IncludeKey {
            }
            @HalleyModel
            struct Model {
                @HalleyCodingKey("test_value")
                let testValue: String
                var myValue: String
                @HalleyCodingKey(nil)
                let skippedValue: String? = ""
            }
            """,
            expandedSource: """
            protocol IncludeKey {
            }
            struct Model {
                let testValue: String
                var myValue: String
                let skippedValue: String? = ""

                let _links: Halley.Links?

                enum CodingKeys: String, CodingKey, IncludeKey {
                    case testValue = "test_value"
                    case myValue
                    case _links
                }
            }

            extension Model: HalleyCodable {
            }
            """,
            macros: macros
        )
    }

    @Test("Public struct")
    func testPublicStruct() throws {
        assertMacroExpansionWithSwiftTesting(
            """
            protocol IncludeKey {
            }
            @HalleyModel
            public struct Model {
                @HalleyCodingKey("test_value")
                public let testValue: String
                public var myValue: String
                var internalValue: String
                @HalleyCodingKey(nil)
                let skippedValue: String? = ""
            }
            """,
            expandedSource: """
            protocol IncludeKey {
            }
            public struct Model {
                public let testValue: String
                public var myValue: String
                var internalValue: String
                let skippedValue: String? = ""

                public let _links: Halley.Links?

                public enum CodingKeys: String, CodingKey, IncludeKey {
                    case testValue = "test_value"
                    case myValue
                    case internalValue
                    case _links
                }
            }

            extension Model: HalleyCodable {
            }
            """,
            macros: macros
        )
    }
}

func assertMacroExpansionWithSwiftTesting(
    _ originalSource: String,
    expandedSource expectedExpandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    macros: [String: any Macro.Type],
    applyFixIts: [String]? = nil,
    fixedSource expectedFixedSource: String? = nil,
    testModuleName: String = "TestModule",
    testFileName: String = "test.swift",
    indentationWidth: Trivia = .spaces(4),
    sourceLocation: Testing.SourceLocation = SourceLocation(fileID: #fileID, filePath: #filePath, line: #line, column: #column)
) {
    let macroSpecs = macros.mapValues { MacroSpec(type: $0) }
    SwiftSyntaxMacrosGenericTestSupport.assertMacroExpansion(
        originalSource,
        expandedSource: expectedExpandedSource,
        diagnostics: diagnostics,
        macroSpecs: macroSpecs,
        applyFixIts: applyFixIts,
        fixedSource: expectedFixedSource,
        testModuleName: testModuleName,
        testFileName: testFileName,
        indentationWidth: indentationWidth,
        failureHandler: {
            #expect(Bool(false), .init(stringLiteral: $0.message), sourceLocation: sourceLocation)
        },
        fileID: "", // Not used in the failure handler
        filePath: "", // Not used in the failure handler
        line: UInt(sourceLocation.line),
        column: 0 // Not used in the failure handler
    )
}
