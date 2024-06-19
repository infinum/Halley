import SwiftSyntax
import SwiftSyntaxBuilder

struct HalleyCodingKeysGenerator {

    let properties: [HalleyPropertyDecl]
    let isPublic: Bool

    func generate() -> EnumDeclSyntax {
        return EnumDeclSyntax(
            modifiers: isPublic ? DeclModifierListSyntax { DeclModifierSyntax(name: .keyword(.public)) } : [],
            name: "CodingKeys",
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "String"))
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "CodingKey"))
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "IncludeKey"))
            }
        ) {
            // Some properties can be skipped via @HalleySkip attribute
            let availableEnumCases = properties.compactMap { $0.generateEnumCase() }
            return MemberBlockItemListSyntax(
                availableEnumCases
                    .map {
                        MemberBlockItemSyntax(
                            decl: EnumCaseDeclSyntax(
                                elements: EnumCaseElementListSyntax(arrayLiteral: $0)
                            )
                        )
                    }
            )
        }
    }
}
