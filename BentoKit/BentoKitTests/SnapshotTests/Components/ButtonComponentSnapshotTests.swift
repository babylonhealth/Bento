import BentoKit
import StyleSheets
import BentoKitPlaygroundSupport
import UIKit

final class ButtonComponentSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    var styleSheet: Component.Button.StyleSheet {
        return Component.Button.StyleSheet(
            button: .init(
                titleColors: [
                    .normal: .white
                ],
                backgroundImages: [
                    .normal: UIImage.image(fromColor: .blue)
                ]
            ),
            activityIndicator: .init(activityIndicatorViewStyle: .white)
        )
    }

    func test_button_with_title_not_loading() {
        let component = Component.Button(title: "Pay", isLoading: false, styleSheet: styleSheet)
        verifyComponentForAllSizes(component: component)
    }

    func test_button_loading() {
        UIView.setAnimationsEnabled(false)
        let component = Component.Button(isLoading: true, styleSheet: styleSheet)
        verifyComponentForAllSizes(component: component)
    }

    func test_button_loading_asymmetric_layout_margins() {
        UIView.setAnimationsEnabled(false)
        let styleSheet = self.styleSheet
            .compose(\.layoutMargins, UIEdgeInsets(top: 128, left: 8, bottom: 8, right: 64))
            .compose(\.backgroundColor, .cyan)
        let component = Component.Button(isLoading: true, styleSheet: styleSheet)
        verifyComponentForAllSizes(component: component)
    }

    func test_multiline_button() {
        UIView.setAnimationsEnabled(false)
        let styleSheet = self.styleSheet
            .compose(\.backgroundColor, .cyan)
            .compose(\.button.numberOfLines, 0)

        let longText = Array(repeating: "Long Text", count: 8).joined()

        let component = Component.Button(
            title: longText,
            isLoading: false,
            styleSheet: styleSheet
        )
        verifyComponentForAllSizes(component: component)
    }

    func test_hugs_content() {
        UIView.setAnimationsEnabled(false)
        let styleSheet = self.styleSheet
            .compose(\.backgroundColor, .cyan)
            .compose(\.hugsContent, true)

        let component = Component.Button(
            title: "Play",
            isLoading: false,
            styleSheet: styleSheet
        )
        verifyComponentForAllSizes(component: component)
    }
}
