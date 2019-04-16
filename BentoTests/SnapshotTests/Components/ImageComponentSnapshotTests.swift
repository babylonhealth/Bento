import XCTest
import Bento
import StyleSheets

final class ImageComponentSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func testImageWithInfoStyle() {
        let image = self.image(named: "iconUnabletoConnect")
        let styleSheet = Component.Image.StyleSheet()
            .compose(\.layoutMargins.bottom, 16)
        let component = Component.Image(image: image, styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }

    func testWithAccessory() {
        let image = self.image(named: "placeholderProfile")
        let closeIcon = self.image(named: "deleteIcon")
        let styleSheet = Component.Image.StyleSheet(
            accessory: ButtonStyleSheet(images: [
                .normal: closeIcon
                ])
            )
            .compose(\.layoutMargins, UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30))
            .compose(\.clipsToBounds, false)
            .compose(\.image.backgroundColor, .purple)
            .compose(\.accessory.backgroundColor, .green)

        let component = Component.Image(image: image, styleSheet: styleSheet, didTapAccessory: {})

        verifyComponentForAllSizes(component: component)
    }
}
