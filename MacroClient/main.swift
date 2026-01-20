import Halley
import HalleyMacro

@HalleyModel
struct Info {
    let text: String
}

@HalleyModel
struct Model {
    @HalleyCodingKey("test_value")
    let testValue: String
    var myValue: String

    @HalleyCodingKey("my_info")
    let primaryInfo: Info?
    @HalleyCodingKey("secondary_info")
    let secondaryInfo: Info?

    @HalleyCodingKey(nil)
    let skippedValue: String? = ""
}

extension Model: IncludableType {

    enum IncludeType {
        case minimum
        case secondaryInfo
    }
}

extension Model.IncludeType: IncludeTypeInterface {
    typealias IncludeCodingKey = Model.CodingKeys

    @IncludesBuilder<IncludeCodingKey>
    func prepareIncludes() -> [IncludeField] {
        switch self {
        case .minimum:
            ToOne(.primaryInfo)
        case .secondaryInfo:
            ToOne(.primaryInfo)
            ToOne(.secondaryInfo)
        }
    }
}

let model = Model(testValue: "value1", myValue: "value2", primaryInfo: nil, secondaryInfo: nil, _links: nil)
let mirror = Mirror(reflecting: model)
mirror.children.forEach {
    print("name: \(String(describing: $0.label)) type: \(type(of: $0.value))")
}
