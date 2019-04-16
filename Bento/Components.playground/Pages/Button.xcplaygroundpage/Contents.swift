import UIKit
import Bento
@testable import BentoPlaygroundSupport
import PlaygroundSupport

let styleSheet = Component.Button.StyleSheet(
    button: ButtonStyleSheet(
        textFont: UIFont.preferredFont(forTextStyle: .callout),
        backgroundImages: [
            .normal: UIImage.image(fromColor: .green),
            .disabled: UIImage.image(fromColor: UIColor.green.withAlphaComponent(0.3))
        ]
        )
    )
    .compose(\.cornerRadius, 6.0)
    .compose(\.masksToBounds, true)
    .compose(\.backgroundColor, .yellow)

PlaygroundPage.current.liveView = renderInTableView(nodes: [
    Node(id: 0,
         component: Component.Button(
            title: "Button",
            isEnabled: true,
            isLoading: false,
            didTap: {
                print("didTap")
         },
            styleSheet: styleSheet
        )
    ),
    Node(id: 1,
         component: Component.Button(
            title: "Button",
            isEnabled: false,
            isLoading: false,
            didTap: {
                print("didTap")
         },
            styleSheet: styleSheet
        )
    ),
    Node(id: 2,
         component: Component.Button(
            title: "Button",
            isEnabled: false,
            isLoading: true,
            didTap: {
                print("didTap")
            },
            styleSheet: styleSheet
        )
    ),
])


