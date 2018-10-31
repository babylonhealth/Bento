import UIKit
import Bento
import BentoKit
import BentoKitPlaygroundSupport
import PlaygroundSupport
import StyleSheets
import ReactiveSwift

let bundle = Bundle(for: Component.TextInput.self)
let image = UIImage(named: "tickIcon", in: bundle, compatibleWith: nil)!

let component = Component.TitledDescription(
    texts: [
        TextValue.plain("Text 1"),
        TextValue.plain("Text 2"),
        TextValue.plain("Text 3"),
        TextValue.plain("Text 4")
    ],
    detail: TextValue.plain("Detail"),
    image: Property(value: ImageOrLabelView.Content.image(image)),
    accessory: Component.TitledDescription.Accessory.checkmark,
    isEnabled: true,
    didTap: {
        print("didTap")
},
    didTapAccessory: {
        print("didTapAccessory")
},
    deleteAction: .action(title: "Delete") {
        print("didDelete")
    },
    styleSheet: Component.TitledDescription.StyleSheet(textStyles: [
        .init(),
        .init(),
        .init(),
        .init()
    ])
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
