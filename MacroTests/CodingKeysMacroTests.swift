import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import HalleyMacro
@testable import HalleyMacroPlugin

final class CodingKeysMacroTests: XCTestCase {
    let macros: [String: Macro.Type] = [
        "HalleyModel": HalleyModelMacro.self,
        "HalleyLink": HalleyLinkMacro.self
    ]

    func testOptionAll() throws {
        assertMacroExpansion(
            """
            protocol IncludeKey {
            }
            @HalleyModel
            struct Hoge {
                @HalleyLink("hoges_link")
                let hogeHoge: String
                var myValue: String
                @HalleyLink(nil)
                let skippyValue: String? = ""
            }
            """,
            expandedSource: """
            protocol IncludeKey {
            }
            struct Hoge {
                let hogeHoge: String
                var myValue: String
                let skippyValue: String? = ""
                let _links: Halley.Links?
                enum CodingKeys: String, CodingKey, IncludeKey {
                    case hogeHoge = "hoges_link"
                    case myValue
                    case _links
                }
            }
            extension Hoge: HalleyCodable {
            }
            """,
            macros: macros
        )
    }
}
