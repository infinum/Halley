import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct HalleyModelMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HalleyModelMacro.self,
        HalleyCodingKeyMacro.self
    ]
}
