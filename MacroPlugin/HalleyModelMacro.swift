import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HalleyModelMacro: MemberMacro {

    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        // Halley models can only be either class, struct or actor - it makes no sense to have
        // enum, function or any other kind as a Halley model
        guard
            let idDecl = declaration as? IdentifiedDeclSyntax,
            idDecl is ClassDeclSyntax || idDecl is StructDeclSyntax || idDecl is ActorDeclSyntax
        else {
            context.diagnose(
                HalleyModelMacroDiagnostic
                    .requiresStructOrClass
                    .diagnose(at: declaration)
            )
            return []
        }

        let modifiers = declaration.modifiers?.map(\.name) ?? []
        let publicKeyword = TokenSyntax.keyword(.public)
        let isPublic = modifiers.map(\.text).contains(publicKeyword.text)

        let linksVariableGenerator = HalleyLinksMemberGenerator(isPublic: isPublic)

        var properties = getProperties(of: declaration, in: context)
        // Cover _links variable since it is not part of standard declaration
        properties.append(linksVariableGenerator.property())
        let enumGenerator = HalleyCodingKeysGenerator(properties: properties, isPublic: isPublic)

        let codingKeysEnum = enumGenerator
            .generate()
            .formatted()
            .as(EnumDeclSyntax.self)!

        return [
            linksVariableGenerator.generate(),
            DeclSyntax(codingKeysEnum)
        ]
    }
}

private extension HalleyModelMacro {

    static func getProperties<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of decl: Declaration,
        in context: Context
    ) -> [HalleyPropertyDecl] {
        let members = decl
            .memberBlock
            .members
        let variables = members.compactMap { $0.decl.as(VariableDeclSyntax.self) } // Accept only variables
        return variables
            .compactMap { variable -> HalleyPropertyDecl? in
                guard
                    let binding = variable.bindings.first,
                    let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                else { return nil }
                // Get custom defined link keys - ones different from default CodingKeys
                let linkType = extractCustomLinkKey(from: variable, in: context)
                return HalleyPropertyDecl(name: name, linkType: linkType)
            }
    }

    static func extractCustomLinkKey<Context: MacroExpansionContext>(
        from variable: VariableDeclSyntax,
        in context: Context
    ) -> HalleyPropertyDecl.LinkType {
        // If there is no HalleyLunk attribute, use default Codable CodingKey value
        guard let attributes = variable.attributes else { return .`default` }
        // Extract only HalleyLink attribute
        let linkAttribute = attributes
            .compactMap { $0.as(AttributeSyntax.self) }
            .first {
                $0.attributeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == "HalleyLink"
            }

        // HalleyLink should have one and only one attribute
        guard
            let linkAttribute,
            case let .argumentList(arguments) = linkAttribute.argument,
            let firstElement = arguments.first?.expression
        else {
            context.diagnose(HalleyModelMacroDiagnostic.noArgument.diagnose(at: variable))
            return .`default`
        }

        // Passed attribute is a String literal
        if
            let linkLiteral = firstElement.as(StringLiteralExprSyntax.self),
            let linkKey = linkLiteral.representedLiteralValue
        {
            return .custom(linkKey)
        } else if firstElement.is(NilLiteralExprSyntax.self) {
            return .skip
        } else {
            context.diagnose(
                HalleyModelMacroDiagnostic
                    .invalidArgument("Only String or nil literals are allowed.")
                    .diagnose(at: firstElement)
            )
            return .default
        }
    }
}

extension HalleyModelMacro: ConformanceMacro {

    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingConformancesOf declaration: Declaration,
        in context: Context
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [ ("HalleyCodable", nil) ]
    }
}
