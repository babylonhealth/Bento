import UIKit
import Bento
import BentoPlaygroundSupport
import PlaygroundSupport

let component = Component.DatePicker(
    date: Date(),
    minDate: Date(timeIntervalSince1970: 0),
    datePickerMode: .date,
    styleSheet: Component.DatePicker.StyleSheet(),
    didPickDate: {
        print("didPickDate", $0)
    }
)

PlaygroundPage.current.liveView = renderInTableView(component: component)
