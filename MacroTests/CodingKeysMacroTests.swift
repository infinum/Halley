import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import HalleyMacro
@testable import HalleyMacroPlugin

final class CodingKeysMacroTests: XCTestCase {
    let macros: [String: Macro.Type] = [
        "HalleyModel": HalleyModelMacro.self,
        "HalleyCodingKey": HalleyCodingKeyMacro.self
    ]

    func testInternalStruct() throws {
        assertMacroExpansion(
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

    func testPublicStruct() throws {
        assertMacroExpansion(
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
