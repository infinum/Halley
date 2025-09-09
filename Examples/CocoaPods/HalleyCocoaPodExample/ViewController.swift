import UIKit
import Halley
import HalleyMacro

@HalleyModel
public struct MyModel {

    let out: String
    @HalleyCodingKey("my_links")
    let myLinks: String

    @HalleyCodingKey("my_link")
    let myLink: String = "sdfds"

    @HalleyCodingKey(nil) // Way to ignore the link
    var ignoredLink: String?

}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(HalleyKit.Options.default)
    }
}
