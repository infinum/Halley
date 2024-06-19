import Foundation
import Halley

struct StepItemResponse: HalleyCodable {
    let _links: Links?
    let code: String?
    let stepItems: [StepItem]?
    let mainStepItem: StepItem?

    enum CodingKeys: String, CodingKey, IncludeKey {
        case _links
        case code
        case stepItems
        case mainStepItem
    }
}

extension StepItemResponse: IncludableType {
    enum IncludeType {
        case all
    }
}

extension StepItemResponse.IncludeType: IncludeTypeInterface {
    typealias IncludeCodingKey = StepItemResponse.CodingKeys

    @IncludesBuilder<IncludeCodingKey>
    func prepareIncludes() -> [IncludeField] {
        switch self {
        case .all:
            ToMany(.stepItems)
            ToOne(.mainStepItem)
        }
    }
}
