import Bento
import StyleSheets
import ReactiveSwift
import UIKit

final class TitledDescriptionLegacySnapshotTests: SnapshotTestCase {

    var styleSheet: Component.TitledDescription.StyleSheet {
        return Component.TitledDescription.StyleSheet(
            textStyles: [
                LabelStyleSheet(
                    backgroundColor: .blue,
                    font: UIFont.preferredFont(forTextStyle: .body)
                ),
                LabelStyleSheet(
                    font: UIFont.preferredFont(forTextStyle: .footnote),
                    textColor: .gray
                )
            ],
            detail: LabelStyleSheet(
                backgroundColor: .green,
                font: UIFont.preferredFont(forTextStyle: .body),
                textAlignment: .trailing)
        )
    }

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_has_chevron() {
        let component = Component.TitledDescription(
            texts: ["Title", "Subtitle"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            accessory: .chevron,
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_no_chevron() {
        let component = Component.TitledDescription(
            texts: ["Title", "Subtitle"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_is_loading() {
        let component = Component.TitledDescription(
            texts: ["Title", "Subtitle"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            accessory: .activityIndicator,
            didTap: {},
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_checkmark() {
        let component = Component.TitledDescription(
            texts: ["Title", "Subtitle"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            accessory: .checkmark,
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_icon() {
        let component = Component.TitledDescription(
            texts: ["Title", "Subtitle"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            accessory: .icon(image(named: "plus")),
            styleSheet: styleSheet
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_image_fixed_size() {
        let component = Component.TitledDescription(
            texts: ["Title", "Subtitle"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            image: Property(value: .image(image(named: "skeleton"))),
            styleSheet: styleSheet
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 128, height: 128))
                .compose(\.imageOrLabel.cornerRadius, 64)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_text_image_placeholder() {
        let component = Component.TitledDescription(
            texts: ["Title", "Subtitle"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            image: Property(value: .text("SJ")),
            styleSheet: styleSheet
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
        let component = Component.TitledDescription(
            texts: ["Title"].map(TextValue.plain),
            detail: TextValue.plain("Detail"),
            accessory: .chevron,
            styleSheet: styleSheet
                .compose(\.textBlockWidthFraction, 0.3)
                .compose(\.detail.textAlignment, .leading)
        )

        verifyComponentForAllSizes(component: component)
    }
}
