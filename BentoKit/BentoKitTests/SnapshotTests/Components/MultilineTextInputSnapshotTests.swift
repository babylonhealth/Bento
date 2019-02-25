import Bento
import BentoKit
import StyleSheets
import UIKit

final class MultilineTextInputSnapshotTests: SnapshotTestCase {
    private let loremIpsum = String(repeating: "Lorem Ipsum ", count: 32)
    private let styleSheet = Component.MultilineTextInput.StyleSheet(
            placeholderTextColor: .lightGray
        )
        .compose(\.layoutMargins, UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func testShowingMultilineText() {
        let component = Component.MultilineTextInput(text: loremIpsum,
                                                     placeholder: "",
                                                     didFinishEditing: { _ in },
                                                     styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }

    func testShowingPlaceholderWhenHavingNoText() {
        let component = Component.MultilineTextInput(text: "",
                                                     placeholder: "No Text",
                                                     didFinishEditing: { _ in },
                                                     styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }

    func test_ShowingPlaceholder_WhenHavingNoText_WithContentStyle() {
        let component = Component.MultilineTextInput(
            text: "",
            placeholder: "No Text",
            didFinishEditing: { _ in },
            styleSheet: Component.MultilineTextInput.StyleSheet(
                placeholderTextColor: .darkGray,
                content: ViewStyleSheet()
                    .compose(\.backgroundColor, .lightGray)
                    .compose(\.cornerRadius, 10)
                    .compose(\.masksToBounds, true)
            )
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_ShowingMultilineText_WithContentStyle() {
        let component = Component.MultilineTextInput(
            text: loremIpsum,
            placeholder: "",
            didFinishEditing: { _ in },
            styleSheet: Component.MultilineTextInput.StyleSheet(
                placeholderTextColor: .darkGray,
                content: ViewStyleSheet()
                    .compose(\.backgroundColor, .lightGray)
                    .compose(\.cornerRadius, 10)
                    .compose(\.masksToBounds, true)
            )
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_ShowingPlaceholder_WhenHavingNoText_WithContentStyle_WithSendButton() {
        let component = Component.MultilineTextInput(
            text: "",
            placeholder: "No Text",
            showsSendButton: true,
            didFinishEditing: { _ in },
            styleSheet: Component.MultilineTextInput.StyleSheet(
                placeholderTextColor: .darkGray,
                content: ViewStyleSheet()
                    .compose(\.backgroundColor, .lightGray)
                    .compose(\.cornerRadius, 10)
                    .compose(\.masksToBounds, true),
                send: ButtonStyleSheet()
                .compose(\.backgroundColor, .red)
                .compose(\.cornerRadius, 5)
                .compose(\.masksToBounds, true)
            )
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_ShowingMultilineText_WithContentStyle_WithSendButton() {
        let component = Component.MultilineTextInput(
            text: loremIpsum,
            placeholder: "",
            showsSendButton: true,
            didFinishEditing: { _ in },
            styleSheet: Component.MultilineTextInput.StyleSheet(
                placeholderTextColor: .darkGray,
                content: ViewStyleSheet()
                    .compose(\.backgroundColor, .lightGray)
                    .compose(\.cornerRadius, 10)
                    .compose(\.masksToBounds, true),
                send: ButtonStyleSheet()
                .compose(\.backgroundColor, .red)
                .compose(\.cornerRadius, 5)
                .compose(\.masksToBounds, true)
            )
        )

        verifyComponentForAllSizes(component: component)
    }
}
