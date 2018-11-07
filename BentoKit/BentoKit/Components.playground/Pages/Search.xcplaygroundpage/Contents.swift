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
    didBeginEditing: { _ in
        print("didBeginEditing")
},
    textDidChange: { _, text in
        print("textDidChange", text)
},
    cancelButtonClicked: {
        print("cancelButtonClicked")
        $0.endEditing(true)
},
    styleSheet: styleSheet
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
