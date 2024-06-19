import Halley
import HalleyMacro

@HalleyModel
struct Hoge {
    @HalleyLink("hoges_link")
    let hogeHoge: String
    var myValue: String
    @HalleyLink(nil)
    let skippyValue: String? = ""
}
