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
    let templateManager = URITemplateManager()

    override func viewDidLoad() {
        super.viewDidLoad()
//        templateManager.setupTemplates()
        exampleSingleResource()
//        exampleResourceCollection()
        exampleWithTemplatedLink()

//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            self.bag = .init()
//        }
    }

    func exampleSingleResource() {
        hal
            .resource(
                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/21666e8f-c9cb-4fad-9490-91a35fcb7106")!, // multi step
                //                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/017345cd-cbb7-47d2-90f5-6e70b25daa83")!, // single step
                includes: ["[steps].[translations]", "[steps].image.collection"] //,// "steps.image.collection"]
            )
            .map { try! $0.get() }
            .sink { result in
                let data = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                let string = String(data: data, encoding: .utf8)!
                print(string)
            }
            .store(in: &bag)
    }

    func exampleResourceCollection() {
        hal
            .resourceCollection(
                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/21666e8f-c9cb-4fad-9490-91a35fcb7106/Step")!,
                includes: ["image.[collection]"] // NOTE: `image` is embeded
            )
            .map { try! $0.get() }
            .sink { result in
                let data = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                let string = String(data: data, encoding: .utf8)!
                print(string)
            }
            .store(in: &bag)
    }

    func exampleWithTemplatedLink() {
        var parameters: [String: [URLQueryItem]] = [
            "[recipes].categories": [URLQueryItem(name: "status", value: "TEST")]
        ]
        hal
            .resource(
                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/21666e8f-c9cb-4fad-9490-91a35fcb7106")!,
                includes: ["[recipes].categories"],
                linkResolver: TemplateLinkResolver(parameters: parameters)
            )
            .map { try! $0.get() }
            .sink { result in
                let data = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                let string = String(data: data, encoding: .utf8)!
                print(string)
            }
            .store(in: &bag)

        parameters = [
            "[steps].[translations]": [URLQueryItem(name: "status", value: "TEST")]
        ]
        hal
            .resource(
                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/21666e8f-c9cb-4fad-9490-91a35fcb7106")!, // multi step
                //                from: URL(string: "https://dev.backend.ka.philips.com/api/Article/017345cd-cbb7-47d2-90f5-6e70b25daa83")!, // single step
                includes: ["[steps].[translations]", "[steps].image.collection"], //,// "steps.image.collection"]
                linkResolver: TemplateLinkResolver(parameters: parameters)
            )
            .map { try! $0.get() }
            .sink { result in
                let data = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                let string = String(data: data, encoding: .utf8)!
                print(string)
            }
            .store(in: &bag)
    }
}
