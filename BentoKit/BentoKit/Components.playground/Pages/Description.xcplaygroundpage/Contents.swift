import Bento
import BentoKit
import BentoKitPlaygroundSupport
import PlaygroundSupport
import StyleSheets

let bundle = Bundle(for: Component.Description.self)

let component = Component.Description(
    text: Array(repeating: "Hello world ", count: 5).joined(),
    accessoryIcon: UIImage(named: "tickIcon", in: bundle, compatibleWith: nil),
    didTap: {
        print("didTap")
    },
    didTapAccessoryButton: {
        print("didTapAccessoryButton")
    },
    styleSheet: Component.Description.StyleSheet()
        .compose(\.backgroundColor, .yellow)
        .compose(\.text.backgroundColor, .green)
        .compose(\.accessoryButton.backgroundColor, .purple)
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
