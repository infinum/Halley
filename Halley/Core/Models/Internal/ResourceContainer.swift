import Foundation

class ResourceContainer {
    let parameters: Parameters
    let _links: Links?

    init(_ parameters: Parameters) {
        var _parameters = parameters
        _links = try? parameters.decode(Links.self, at: HalleyConsts.links)
        let _embedded = parameters[HalleyConsts.embedded] as? [String: Any]
        // Adds embedded resources to the result dictionary
        _embedded?.forEach({ _parameters[$0.key] = $0.value })
        _parameters.removeValue(forKey: HalleyConsts.embedded)
        self.parameters = _parameters
    }

    func hasEmbeddedRelationship(_ relationship: String) -> Bool {
        return parameters[relationship] != nil
    }
}
