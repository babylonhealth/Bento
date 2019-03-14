import UIKit
import Bento
import BentoKit
import BentoKitPlaygroundSupport
import PlaygroundSupport
import StyleSheets

let component = Component.MultilineTextInput(
    text: "This is UITextView.\nClick me!",
    placeholder: "Placeholder",
    didFinishEditing: {
        print("didFinishEditing", $0)
    },
    styleSheet: Component.MultilineTextInput.StyleSheet(
        font: UIFont.preferredFont(forTextStyle: .title1),
        textColor: .blue,
        placeholderTextColor: .darkText
    )
)

PlaygroundPage.current.liveView = renderInTableView(
    component: component,
    size: CGSize.iPhoneX
)
