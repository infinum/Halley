//
//  ViewController.swift
//  Halley
//
//  Created by Filip Gulan on 01/15/2022.
//  Copyright (c) 2022 Filip Gulan. All rights reserved.
//

import UIKit
import Combine
import Halley

class ViewController: UIViewController {

    var bag = Set<AnyCancellable>()
    var hal = ResourceManager(requester: HALAlamofireRequester())

    override func viewDidLoad() {
        super.viewDidLoad()
//        hal
//            .resource(
//                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/21666e8f-c9cb-4fad-9490-91a35fcb7106")!, // multi step
////                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/017345cd-cbb7-47d2-90f5-6e70b25daa83")!, // single step
//                includes: ["[steps].[translations]", "[steps].image.collection"] //,// "steps.image.collection"]
//            )
//            .map { try! $0.get() }
//            .sink { result in
//                let data = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                let string = String(data: data, encoding: .utf8)!
//                print(string)
//            }
//            .store(in: &bag)


            hal
                .resourceCollection(
                    from: URL(string: "https://dev.backend.ka.philips.com/api/Article/21666e8f-c9cb-4fad-9490-91a35fcb7106/Step")!,
                    includes: ["image.[collection]"]
                )
                .map { try! $0.get() }
                .sink { result in
                    let data = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    let string = String(data: data, encoding: .utf8)!
                    print(string)
                }
                .store(in: &bag)


//        hal
//            .resourceCollection(
//                from: URL(string: "https://dev.backend.ka.philips.com/api/Collection$inspirational?category=AIR_COOKER,AIRFRYER,NONE,RECIPE_BOOK&status=LIVE,LIVE_FLAGGED&country=DE&includePremium=false&page=1&size=5")!,
//                includes: ["[translations]", "image"]
//            )
//            .map { try! $0.get() }
//            .sink { result in
//                let data = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                let string = String(data: data, encoding: .utf8)!
//                print(string)
//            }
//            .store(in: &bag)

//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            self.bag = .init()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
