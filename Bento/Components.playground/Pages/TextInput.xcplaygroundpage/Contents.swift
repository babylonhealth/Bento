import UIKit
import Bento
import BentoPlaygroundSupport
import PlaygroundSupport
import StyleSheets

let bundle = Bundle(for: Component.TextInput.self)
let styleSheet = Component.TextInput.StyleSheet()
let component = Component.TextInput(
    title: "Title",
    placeholder: "Placeholder",
    text: nil,
    keyboardType: .default,
    accessory: .icon(UIImage(named: "tickIcon", in: bundle, compatibleWith: nil)!),
    textWillChange: nil,
    textDidChange: {
        print("textDidChange", $0)
    },
    didTapAccessory: {
        print("didTapAccessory")
    },
    styleSheet: styleSheet
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
