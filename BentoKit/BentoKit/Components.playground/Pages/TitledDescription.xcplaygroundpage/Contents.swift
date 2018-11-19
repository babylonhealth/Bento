import UIKit
import Bento
import BentoKit
import BentoKitPlaygroundSupport
import PlaygroundSupport
import StyleSheets
import ReactiveSwift

let bundle = Bundle(for: Component.TextInput.self)
let image = UIImage(named: "tickIcon", in: bundle, compatibleWith: nil)!

let button = UIButton(type: .custom)
button.setTitleColor(UIColor.black, for: .normal)
button.setTitle("call", for: .normal)
button.setImage(image, for: .normal)

button.titleEdgeInsets = UIEdgeInsets(top: 37, left: -27, bottom: 0, right: 0)
button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
button.heightAnchor.constraint(equalToConstant: 58).isActive = true
button.widthAnchor.constraint(equalToConstant: 37).isActive = true

let component = Component.TitledDescription(
    texts: [
        TextValue.plain("Text 1"),
        TextValue.plain("Text 2"),
        TextValue.plain("Text 3"),
        TextValue.plain("Text 4")
    ],
    detail: TextValue.plain("Detail"),
    image: Property(value: ImageOrLabelView.Content.image(image)),
    accessory: Component.TitledDescription.Accessory.custom(button),
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
    styleSheet: Component.TitledDescription.StyleSheet(
        textStyles: [
        .init(),
        .init(),
        .init(),
        .init()
    ])
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
