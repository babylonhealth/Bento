import UIKit
import Bento
import BentoKit
import BentoKitPlaygroundSupport
import PlaygroundSupport
import StyleSheets

let bundle = Bundle(for: Component.TextInput.self)
let styleSheet = Component.Search.StyleSheet()
    .compose(\.searchBar.backgroundColor, UIColor.gray.withAlphaComponent(0.25))
.compose(\.searchBar.showsCancelButton, true)
let component = Component.Search(
    placeholder: "Placeholder",
    keyboardType: .default,
    textDidChange: {
        print("textDidChange", $0)
},
    cancelButtonClicked: {
        print("cancelButtonClicked")
},
    styleSheet: styleSheet
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
