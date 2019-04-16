import Bento
import XCTest

class TextInputSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func testTextInput_title_fill_proportionally() {
        let styleSheet = Component.TextInput.StyleSheet(titleStyle: .fillProportionally(0.25))
            .compose(\.layoutMargins, UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        let component = Component.TextInput(
            title: "Title",
            placeholder: "Placeholder",
            text: nil,
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func testTextInput_title_fit() {
        let styleSheet = Component.TextInput.StyleSheet(titleStyle: .fit)
            .compose(\.layoutMargins, UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        let component = Component.TextInput(
            title: "Title",
            placeholder: "Placeholder",
            text: nil,
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func testTextInput_without_title() {
        let styleSheet = Component.TextInput.StyleSheet(titleStyle: .fit)
            .compose(\.layoutMargins, UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        let component = Component.TextInput(
            placeholder: "Placeholder",
            text: nil,
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func testTextInput_with_contentStyle() {
        let styleSheet = Component.TextInput.StyleSheet(
            titleStyle: .fit,
            content: ViewStyleSheet()
                .compose(\.layoutMargins, UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
                .compose(\.backgroundColor, .lightGray)
                .compose(\.cornerRadius, 12)
            )
            .compose(\.layoutMargins, UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

        let component = Component.TextInput(
            placeholder: "Placeholder",
            text: nil,
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func testTextInput_with_text() {
        let styleSheet = Component.TextInput.StyleSheet(titleStyle: .fit)
            .compose(\.layoutMargins, UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        let component = Component.TextInput(
            title: "Title",
            placeholder: "Placeholder",
            text: "Text",
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }
}
