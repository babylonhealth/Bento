import XCTest
import Bento

final class DetailedDescriptionSnapshotTests: SnapshotTestCase {

    func styleSheet(_ count: Int) -> Component.DetailedDescription.StyleSheet {
        let styles = [LabelStyleSheet(backgroundColor: .yellow),
                      LabelStyleSheet(backgroundColor: .blue)]
        let textStyles = (0 ..< count).reduce([]) { current, k in current + [styles[k % 2]] }
        return .init(
            textStyles: textStyles,
            detail: LabelStyleSheet(backgroundColor: .green, textAlignment: .trailing)
        )
    }

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_no_labels_no_image() {
        let component = Component.DetailedDescription(
            texts: [],
            detail: .none,
            accessory: .none,
            styleSheet: styleSheet(0))

        verifyComponentForAllSizes(component: component)
    }

    func test_detail_but_no_vertically_arranged_labels() {
        let component = Component.DetailedDescription(
            texts: [],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(0))

        verifyComponentForAllSizes(component: component)
    }

    func test_detail_and_many_vertically_arranged_labels() {
        let component = Component.DetailedDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(3))

        verifyComponentForAllSizes(component: component)
    }

    func test_no_detail_but_many_vertically_arranged_labels() {
        let component = Component.DetailedDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .none,
            accessory: .none,
            styleSheet: styleSheet(3))

        verifyComponentForAllSizes(component: component)
    }

    func test_no_accessory_icon() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_chevron_accessory_icon() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .chevron,
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_loading_accessory_icon() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .activityIndicator,
            didTap: {},
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_checkmark_accessory_icon() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .checkmark,
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_general_icon_accessory_icon() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .icon(image(named: "plus")),
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_with_custom_accessory_view() {
        let image = UIImageView(image: self.image(named: "plus"))
        image.backgroundColor = .red
        image.heightAnchor.constraint(equalToConstant: 50).isActive = true
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Label 4 is also a fine label but definitely far too long to be considered a good label")],
            detail: .plain("Detail"),
            accessory: .custom(image),
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_considers_custom_accessory_view_size() {
        let image = UIImageView(image: self.image(named: "plus"))
        image.backgroundColor = .red
        image.heightAnchor.constraint(equalToConstant: 150).isActive = true
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Label 4 is also a fine label but definitely far too long to be considered a good label")],
            detail: .plain("Detail"),
            accessory: .custom(image),
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_image_fixed_size() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            image: .image(image(named: "skeleton")),
            styleSheet: styleSheet(2)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 128, height: 128))
                .compose(\.imageOrLabel.cornerRadius, 64)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_text_image_placeholder() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            image: .text("WT"),
            styleSheet: styleSheet(2)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 64, height: 64))
                .compose(\.imageOrLabel.cornerRadius, 32)
                .compose(\.imageOrLabel.backgroundColor, UIColor.purple)
                .compose(\.imageOrLabel.label.textColor, .white)
                .compose(\.imageOrLabel.label.textAlignment, .center)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_fixed_title_width() {
        let component = Component.DetailedDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .chevron,
            styleSheet: styleSheet(2)
                .compose(\.textBlockWidthFraction, 0.3)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_chevron_image_fixed_size_many_labels_and_detail() {
        let component = Component.DetailedDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3"),
                    .plain("Label 4"),
                    .plain("Label 5")],
            detail: .plain("Detail"),
            image: .image(image(named: "skeleton")),
            accessory: .chevron,
            styleSheet: styleSheet(5)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 128, height: 128))
                .compose(\.imageOrLabel.cornerRadius, 64)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_chevron_image_fixed_size_some_empty_labels_and_detail() {
        let component = Component.DetailedDescription(
            texts: [.plain("Label 1"),
                    .plain(""),
                    .plain("Label 3"),
                    .plain(""),
                    .plain("Label 5")],
            detail: .plain("Detail"),
            image: .image(image(named: "skeleton")),
            accessory: .chevron,
            styleSheet: styleSheet(5)
                .compose(\.textBlockWidthFraction, 0.3)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 128, height: 128))
                .compose(\.imageOrLabel.cornerRadius, 64)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_chevron_image_fixed_size_many_multi_line_labels_and_detail() {
        let component = Component.DetailedDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2 is a fine label but perhaps a little too long"),
                    .plain("Label 3"),
                    .plain("Label 4 is also a fine label but definitely far too long to be considered a good label"),
                    .plain("Label 5")],
            detail: .plain("Detail"),
            image: .image(image(named: "skeleton")),
            accessory: .chevron,
            styleSheet: styleSheet(5)
                .compose(\.textBlockWidthFraction, 0.4)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 100, height: 100))
                .compose(\.imageOrLabel.cornerRadius, 50)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_long_text_with_2_lines_limit() {
        let component = Component.DetailedDescription(
            texts: [
                .plain(Array(repeating: "Label 1 ", count: 20).joined()),
                .plain(Array(repeating: "Label 2 ", count: 20).joined()),
                ],
            accessory: .chevron,
            styleSheet: styleSheet(2)
                .compose(\.textStyles[0].numberOfLines, 2)
                .compose(\.textStyles[1].numberOfLines, 2)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_long_detail_with_fraction() {
        let component = Component.DetailedDescription(
            texts: [
                .plain(Array(repeating: "Address", count: 10).joined(separator: " "))
            ],
            detail: "Megahight.com, 1 Lily Close 1 Lily Close",
            accessory: .chevron,
            styleSheet: Component.DetailedDescription.StyleSheet(textBlockWidthFraction: 0.25)
                .compose(\.detail.textColor, .gray)
                .compose(\.detail.backgroundColor, .green)
                .compose(\.textStyles[0].backgroundColor, .red)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_long_detail_with_fraction_and_fixed_number_of_lines() {
        let component = Component.DetailedDescription(
            texts: [
                .plain(Array(repeating: "Address", count: 10).joined(separator: " "))
            ],
            detail: "Megahight.com, 1 Lily Close 1 Lily Close",
            accessory: .chevron,
            styleSheet: Component.DetailedDescription.StyleSheet(textBlockWidthFraction: 0.25)
                .compose(\.detail.textColor, .gray)
                .compose(\.detail.backgroundColor, .green)
                .compose(\.textStyles[0].backgroundColor, .red)
                .compose(\.textStyles[0].numberOfLines, 2)
        )

        verifyComponentForAllSizes(component: component)
    }
}
