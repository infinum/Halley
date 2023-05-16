import Foundation

public class DefaultTemplateHandler: TemplateHandler {

    // MARK: - Singleton

    public static let shared = DefaultTemplateHandler()

    // MARK: - Properties

    public private(set) var templateValues: [String: () -> String?] = [:]
    public var expandedValues: [String: String] {
        templateValues.compactMapValues { $0() }
    }

    private init() {
        // Singleton pattern
    }

    // MARK: - TemplateHandler

    public func resolveTemplate(for link: Link) throws -> URL {
        return try link.asURL(with: expandedValues)
    }

    // MARK: - Interface

    public func updateTemplate(for key: String, value: @escaping () -> String?) {
        templateValues.updateValue(value, forKey: key)
    }

    public func removeTemplate(for key: String) {
        templateValues.removeValue(forKey: key)
    }
}
