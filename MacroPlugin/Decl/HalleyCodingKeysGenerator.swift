import SwiftSyntax
import SwiftSyntaxBuilder

struct HalleyCodingKeysGenerator {

    let properties: [HalleyPropertyDecl]
    let isPublic: Bool

    func generate() -> EnumDeclSyntax {
        EnumDeclSyntax(
            modifiers: isPublic ? ModifierListSyntax { DeclModifierSyntax(name: .keyword(.public)) } : [],
            identifier: .identifier("CodingKeys"),
            inheritanceClause: TypeInheritanceClauseSyntax {
                InheritedTypeSyntax(typeName: TypeSyntax(stringLiteral: "String"))
                InheritedTypeSyntax(typeName: TypeSyntax(stringLiteral: "CodingKey"))
                InheritedTypeSyntax(typeName: TypeSyntax(stringLiteral: "IncludeKey"))
            }
        ) {
            // Some properties can be skipped via @HalleySkip attribute
            let availableEnumCases = properties.compactMap { $0.generateEnumCase() }
            return MemberDeclListSyntax(
                availableEnumCases
                    .map {
                        MemberDeclListItemSyntax(
                            decl: EnumCaseDeclSyntax(
                                elements: EnumCaseElementListSyntax(arrayLiteral: $0)
                            )
                        )
                    }
            )
        }
    }
}
