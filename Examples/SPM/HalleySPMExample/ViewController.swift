import UIKit
import Halley
import HalleyMacro

@HalleyModel
public struct MyModel {

    let out: String
    @HalleyCodingKey("my_linksic")
    let myLinks: String

    @HalleyCodingKey("my_linksicasdsa")
    let myLink2222s: String = "sdfds"

    @HalleyCodingKey(nil) // Way to ignore the link
    var myLink22sfs22s: String?

}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(HalleyKit.Options.default)
    }
}
