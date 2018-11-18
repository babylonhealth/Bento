import XCTest
import BentoKit
import StyleSheets
import ReactiveSwift
import Bento

final class TitledDescriptionSnapshotTests: SnapshotTestCase {

    func styleSheet(_ count: Int) -> Component.TitledDescription.StyleSheet {
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
    
    func test_performance_customizedHeight() {
        let c = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(3))
        let n = Node<CChar>(id: 0, component: c)
        
        measure {
            for _ in 0 ..< 100_0 {
                withExtendedLifetime(n.component(as: HeightCustomizing.self)!.height(forWidth: 320, inheritedMargins: .zero)) {}
            }
        }
    }

    func test_performance_autoLayoutHeight() {
        let c = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(3))
        
        measure {
            let v = c.generate()
            for _ in 0 ..< 100_0 {
                c.render(in: v)
                withExtendedLifetime(
                    v.systemLayoutSizeFitting(CGSize(width: 320, height: UIView.layoutFittingCompressedSize.height),
                                              withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
                ) {}
            }
        }
    }

    func test_performance_equatable() {
        let c1 = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(3))

        let c2 = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(3))

        measure {
            for _ in 0 ..< 100_0 {
                withExtendedLifetime(c1.props == c2.props) {}
            }
        }
    }


    func test_no_labels_no_image() {
        let component = Component.TitledDescription(
            texts: [],
            detail: .none,
            accessory: .none,
            styleSheet: styleSheet(0))

        verifyComponentForAllSizes(component: component)
    }

    func test_detail_but_no_vertically_arranged_labels() {
        let component = Component.TitledDescription(
            texts: [],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(0))

        verifyComponentForAllSizes(component: component)
    }

    func test_detail_and_many_vertically_arranged_labels() {
        let component = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(3))

        verifyComponentForAllSizes(component: component)
    }

    func test_no_detail_but_many_vertically_arranged_labels() {
        let component = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3")],
            detail: .none,
            accessory: .none,
            styleSheet: styleSheet(3))

        verifyComponentForAllSizes(component: component)
    }

    func test_no_accessory_icon() {
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .none,
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_chevron_accessory_icon() {
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .chevron,
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_loading_accessory_icon() {
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .activityIndicator,
            didTap: {},
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_checkmark_accessory_icon() {
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .checkmark,
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_general_icon_accessory_icon() {
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .icon(image(named: "plus")),
            styleSheet: styleSheet(2))

        verifyComponentForAllSizes(component: component)
    }

    func test_has_image_fixed_size() {
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            image: Property(value: .image(image(named: "skeleton"))),
            styleSheet: styleSheet(2)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 128, height: 128))
                .compose(\.imageOrLabel.cornerRadius, 64)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_text_image_placeholder() {
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            image: Property(value: .text("WT")),
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
        let component = Component.TitledDescription(
            texts: [.plain("Title"), .plain("Subtitle")],
            detail: .plain("Detail"),
            accessory: .chevron,
            styleSheet: styleSheet(2)
                .compose(\.textBlockWidthFraction, 0.3)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_chevron_image_fixed_size_many_labels_and_detail() {
        let component = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2"),
                    .plain("Label 3"),
                    .plain("Label 4"),
                    .plain("Label 5")],
            detail: .plain("Detail"),
            image: Property(value: .image(image(named: "skeleton"))),
            accessory: .chevron,
            styleSheet: styleSheet(5)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 128, height: 128))
                .compose(\.imageOrLabel.cornerRadius, 64)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_has_chevron_image_fixed_size_some_empty_labels_and_detail() {
        let component = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain(""),
                    .plain("Label 3"),
                    .plain(""),
                    .plain("Label 5")],
            detail: .plain("Detail"),
            image: Property(value: .image(image(named: "skeleton"))),
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
        let component = Component.TitledDescription(
            texts: [.plain("Label 1"),
                    .plain("Label 2 is a fine label but perhaps a little too long"),
                    .plain("Label 3"),
                    .plain("Label 4 is also a fine label but definitely far too long to be considered a good label"),
                    .plain("Label 5")],
            detail: .plain("Detail"),
            image: Property(value: .image(image(named: "skeleton"))),
            accessory: .chevron,
            styleSheet: styleSheet(5)
                .compose(\.textBlockWidthFraction, 0.4)
                .compose(\.imageOrLabel.fixedSize, CGSize(width: 100, height: 100))
                .compose(\.imageOrLabel.cornerRadius, 50)
                .compose(\.imageOrLabel.image.contentMode, .scaleAspectFill)
        )

        verifyComponentForAllSizes(component: component)
    }
}
