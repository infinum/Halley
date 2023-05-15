//
//  StepItem.swift
//  Halley_Example
//
//  Created by Filip Gulan on 11.05.2023..
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import Halley

struct StepItem: HalleyCodable {
    let _links: Links?

    let type: String
    let description: String
}
