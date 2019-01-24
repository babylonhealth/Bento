import XCTest
import BentoKit
import StyleSheets
import Bento

final class DescriptionComponentSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_default() {

        let styleSheet = Component.Description.StyleSheet(
            text: LabelStyleSheet(
                font: UIFont.preferredFont(forTextStyle: .headline),
                textAlignment: .center
            )
        )

        let component = Component.Description(text: "Unable to connect", styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }

    func test_chevron() {

        let styleSheet = Component.Description.StyleSheet(
            text: LabelStyleSheet(
                font: UIFont.preferredFont(forTextStyle: .headline)
            ),
            accessoryButton: ButtonStyleSheet()
                .compose(\.tintColor, UIColor.gray)
            )
            .compose(\.layoutMargins.left, 16)
            .compose(\.layoutMargins.right, 16)

        let component = Component.Description(text: "Dr. Amelia Watson",
                                              accessoryIcon: image(named: "chevron_next"),
                                              styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }

    func test_multiline() {
        let styleSheet = Component.Description.StyleSheet(
            text: LabelStyleSheet(
                font: UIFont.preferredFont(forTextStyle: .subheadline),
                textColor: UIColor.gray
            ),
            accessoryButton: ButtonStyleSheet()
                .compose(\ButtonStyleSheet.tintColor, .gray)
            )
            .compose(\.layoutMargins.left, 16)
            .compose(\.layoutMargins.right, 16)

        let text = "Because you reported: Pain at the back of head, sensitivity to bright light and severe headache."
        let component = Component.Description(text: text, styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }

    func test_multiline_in_header_and_footer() {
        let styleSheet = Component.Description.StyleSheet(
            text: LabelStyleSheet(
                font: UIFont.preferredFont(forTextStyle: .subheadline),
                textColor: .gray
            ),
            accessoryButton: ButtonStyleSheet()
                .compose(\ButtonStyleSheet.tintColor, .gray)
            )
            .compose(\.layoutMargins.left, 16)
            .compose(\.layoutMargins.right, 16)

        let text = "Because you reported: Pain at the back of head, sensitivity to bright light and severe headache."
        let component = Component.Description(text: text, styleSheet: styleSheet)

        verifyBoxForAllSizes(
            box: Box<Int, Int>.empty
                |-+ Section(id: 0, header: component, footer: component)
                |---+ Node(id: 0, component:
                    Component.EmptySpace(height: 44, styleSheet: ViewStyleSheet()
                        .compose(\.backgroundColor, .white))
                ),
            style: .grouped,
            separatorStyle: .singleLine
        )
    }

    func test_bold_text_accessory_button() {

        let styleSheet = Component.Description.StyleSheet(
            text: LabelStyleSheet(
                font: UIFont.preferredFont(forTextStyle: .title3)
            ),
            accessoryButton: ButtonStyleSheet()
                .compose(\.tintColor, .gray)
            )
            .compose(\.layoutMargins.left, 16)
            .compose(\.layoutMargins.right, 16)

        let component = Component.Description(text: "Possible Causes",
                                              accessoryIcon: image(named: "info"),
                                              styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }


    func test_long_text_with_2_lines() {
        let styleSheet = Component.Description.StyleSheet(
            text: LabelStyleSheet (
                font: UIFont.preferredFont(forTextStyle: .title3),
                numberOfLines: 2
            ).compose(\.backgroundColor, .green ),
            accessoryButton: ButtonStyleSheet()
                .compose(\.tintColor, .gray)
            )
            .compose(\.layoutMargins.left, 16)
            .compose(\.layoutMargins.right, 16)

        let component = Component.Description(text: Array(repeating: "Text ", count: 20).joined(),
                                              accessoryIcon: image(named: "info"),
                                              styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }
}
