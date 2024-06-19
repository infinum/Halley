import SwiftSyntax
import SwiftSyntaxBuilder

struct HalleyCodingKeysMemberGenerator {

    let linksVariableName: String = "_links"
    let isPublic: Bool

    func generate() -> DeclSyntax {
        let modifiers = DeclModifierListSyntax {
            if isPublic {
                DeclModifierListSyntax { DeclModifierSyntax(name: .keyword(.public)) }
            }
        }
        return DeclSyntax("\(modifiers) let \(raw: linksVariableName): Halley.Links?")
    }

    func property() -> HalleyPropertyDecl {
        return .init(name: linksVariableName, linkType: .default)
    }
}
