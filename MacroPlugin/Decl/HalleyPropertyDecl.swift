import SwiftSyntax
import SwiftSyntaxBuilder

struct HalleyPropertyDecl {

    enum LinkType {
        case `default`
        case custom(String)
        case skip
    }

    let name: String
    let linkType: LinkType

    init(name: String, linkType: LinkType) {
        self.name = name
        self.linkType = linkType
    }

    func generateEnumCase() -> EnumCaseElementSyntax? {
        switch linkType {
        case .custom(let customLinkValue):
            return EnumCaseElementSyntax(
                identifier: .identifier(name),
                rawValue: InitializerClauseSyntax(
                    equal: .equalToken(),
                    value: StringLiteralExprSyntax(content: customLinkValue)
                )
            )
        case .`default`:
            return EnumCaseElementSyntax(identifier: .identifier(name))
        case .skip:
            return nil
        }
    }
}
