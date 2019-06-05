import UIKit
import Bento
import BentoPlaygroundSupport
import PlaygroundSupport

let component = Component.OptionPicker(
    options: [
        "🇬🇧",
        "🇺🇦",
        "🇷🇺",
        "🇵🇹",
        "🇸🇪",
        "🇵🇱",
    ],
    selected: "🇺🇦",
    didPickItem: {
        print("didPickItem", $0)
    }
)

PlaygroundPage.current.liveView = renderInTableView(component: component)

