import Bento
import StyleSheets
import UIKit
@testable import BentoPlaygroundSupport

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
            image: .image(fromColor: .blue, size: CGSize(width: 32, height: 32)),
            styleSheet: styleSheet
        )
        verifyComponentForAllSizes(component: component)
    }

    func test_toggle_with_large_image() {
        let component = Component.Toggle(
            title: title,
            image: .image(fromColor: .red, size: CGSize(width: 128, height: 128)),
            styleSheet: styleSheet
        )
        verifyComponentForAllSizes(component: component)
    }

    func test_toggle_with_large_image_small_title() {
        let component = Component.Toggle(
            title: "Some small title",
            image: .image(fromColor: .red, size: CGSize(width: 128, height: 128)),
            styleSheet: styleSheet
        )
        verifyComponentForAllSizes(component: component)
    }
}
