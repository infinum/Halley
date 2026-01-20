import Foundation

final public class DefaultTemplateHandler: TemplateHandler, @unchecked Sendable {

    // MARK: - Singleton

    public static let shared = DefaultTemplateHandler()

    // MARK: - Properties

    private let lock = NSLock()

    public private(set) var templateValues: [String: () -> String?] = [:]
    public var expandedValues: [String: String] {
        lock.safe {
            templateValues.compactMapValues { $0() }
        }
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
        lock.safe {
            templateValues.updateValue(value, forKey: key)
        }
    }

    public func removeTemplate(for key: String) {
        lock.safe {
            templateValues.removeValue(forKey: key)
        }
    }
}
