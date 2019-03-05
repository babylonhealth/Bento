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
        TextValue.plain(String(repeating: "Lorem Ipsum Hey ", count: 2)),
        TextValue.plain(String(repeating: "Lorem Ipsum Nah ", count: 3))
    ],
    detail: TextValue.plain("Detail"),
    image: Property(value: ImageOrLabelView.Content.image(image)),
    accessory: Component.TitledDescription.Accessory.custom(button),
    didTap: {
        print("didTap")
    },
    didTapAccessory: {
        print("didTapAccessory")
    },
    styleSheet: Component.TitledDescription.StyleSheet(
        textStyles: [
            LabelStyleSheet(textColor: .red),
            LabelStyleSheet(textColor: .orange),
            LabelStyleSheet(textColor: .green),
            LabelStyleSheet(textColor: .blue)
        ]
    )
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
