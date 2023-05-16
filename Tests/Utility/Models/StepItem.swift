import Foundation
import Halley

struct StepItem: HalleyCodable {
    let _links: Links?

    let type: String
    let description: String
}
