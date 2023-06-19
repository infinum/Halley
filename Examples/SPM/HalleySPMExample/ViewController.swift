//
//  ViewController.swift
//  HalleySPMExample
//
//  Created by Filip Gulan on 16.05.2023..
//

import UIKit
import Halley
import HalleyMacro

@HalleyModel
public struct MyModel {

    let out: String
    @HalleyLink("my_linksic")
    let myLinks: String

    @HalleyLink("my_linksicasdsa")
    let myLink2222s: String = "sdfds"

    @HalleyLink(nil) // Way to ignore the link
    var myLink22sfs22s: String?

}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(HalleyKit.Options.default)
    }
}
