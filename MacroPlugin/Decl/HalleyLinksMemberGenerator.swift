import SwiftSyntax
import SwiftSyntaxBuilder

struct HalleyLinksMemberGenerator {

    let linksVariableName: String = "_links"
    let isPublic: Bool

    func generate() -> DeclSyntax {
        return """
        \(isPublic ? "public " : "")let \(raw: linksVariableName): Halley.Links?
        """
    }

    func property() -> HalleyPropertyDecl {
        return .init(name: linksVariableName, linkType: .default)
    }
}
