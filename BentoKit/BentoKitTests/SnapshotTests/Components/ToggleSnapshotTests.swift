import BentoKit
import StyleSheets
import UIKit
@testable import BentoKitPlaygroundSupport

final class ToggleSnapshotTests: SnapshotTestCase {
    private let title = "I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions I agree to the Terms & Conditions "

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    let styleSheet = Component.Toggle.StyleSheet(
        text: LabelStyleSheet(
            font: UIFont.preferredFont(forTextStyle: .headline),
            textAlignment: .leading
        )
    )

    func test_toggle_on() {
        let component = Component.Toggle(title: title, isOn: true, styleSheet: styleSheet)
        verifyComponentForAllSizes(component: component)
    }

    func test_toggle_off() {
        let component = Component.Toggle(title: title, isOn: false, styleSheet: styleSheet)
        verifyComponentForAllSizes(component: component)
    }

    func test_toggle_loading() {
        let component = Component.Toggle(title: title, isRefreshing: true, styleSheet: styleSheet)
        verifyComponentForAllSizes(component: component)
    }

    func test_toggle_with_image() {
        let component = Component.Toggle(
            title: title,
            image: .image(fromColor: .blue),
            styleSheet: styleSheet
        )
        verifyComponentForAllSizes(component: component)
    }

}
