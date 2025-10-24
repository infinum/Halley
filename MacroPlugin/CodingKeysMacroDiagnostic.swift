import SwiftSyntax
import SwiftDiagnostics

enum HalleyModelMacroDiagnostic {
    case noArgument
    case requiresStructOrClass
    case invalidArgument(String)
    case invalidState(String)
}

extension HalleyModelMacroDiagnostic: DiagnosticMessage {

    var severity: DiagnosticSeverity { .error }

    var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "HalleyModelMacro.\(self)")
    }

    var message: String {
        switch self {
        case .noArgument:
            return "Cannot find argument"
        case .requiresStructOrClass:
            return "HalleyModel macro can only be applied to struct or class."
        case .invalidArgument(let message):
            return "Invalid Argument. \(message)"
        case .invalidState(let message):
            return "Invalid State. \(message)"
        }
    }

    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }
}
