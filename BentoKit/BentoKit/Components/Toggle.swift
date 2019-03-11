import Bento
import ReactiveSwift
import StyleSheets

extension Component {
    public final class Toggle: AutoRenderable, HeightCustomizing {
        private let heightComputer: (CGFloat, UIEdgeInsets) -> CGFloat

        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        public init(
            title: String,
            attributedTitle: NSAttributedString? = nil,
            image: Property<BentoKit.ImageOrLabel>? = nil,
            isOn: Bool = false,
            isEnabled: Bool = true,
            isRefreshing: Bool = false,
            animateValueChange: Bool = false,
            styleSheet: StyleSheet,
            didChangeValue: ((Bool) -> Void)? = nil
            ) {

            self.styleSheet = styleSheet
            self.configurator = { view in
                view.didChangeValue = didChangeValue
                view.toggle.setOn(isOn, animated: animateValueChange)
                view.toggle.isEnabled = isEnabled
                view.toggle.isHidden = isRefreshing

                if let attributedTitle = attributedTitle {
                    view.textLabel.attributedText = attributedTitle
                } else {
                    view.textLabel.text = title
                }

                view.disposable = image?.producer.startWithValues(view.imageOrLabelView.reactive.content.action)
                view.imageOrLabelView.isHidden = image == nil
                view.isRefreshing = isRefreshing
            }

            self.heightComputer = Toggle.heightComputer(
                title: title,
                attributedTitle: attributedTitle,
                styleSheet: styleSheet,
                image: image
            )
        }

        public func estimatedHeight(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }

        public func height(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }
    }
}

private extension Component.Toggle {
    static func heightComputer(
        title: String,
        attributedTitle: NSAttributedString? = nil,
        styleSheet: StyleSheet,
        image: Property<ImageOrLabel>?
        ) -> (CGFloat, UIEdgeInsets) -> CGFloat {
        return { width, inheritedMargins in
            guard width > 0 else { return 0 }

            let verticalMargins = styleSheet.layoutMargins.verticalTotal
            let (imageWidth, imageHeight) = actualSizeWithSpacing(measuring: image, styleSheet: styleSheet)
            let textBoundWidth = width
                - max(styleSheet.layoutMargins.left, inheritedMargins.left)
                - max(styleSheet.layoutMargins.right, inheritedMargins.right)
                - Dimensions.toggleWidth
                - Dimensions.horizontalElementsSpacing
                - imageWidth

            let textHeight: CGFloat
            // Needed since we've two different overloads (one for an NSAttributedString and another for plain String)
            if let attributedTitle = attributedTitle {
                textHeight = styleSheet.text.height(of: attributedTitle, fittingWidth: textBoundWidth)
            } else {
                textHeight = styleSheet.text.height(of: title, fittingWidth: textBoundWidth)
            }

            return max(
                styleSheet.enforcesMinimumHeight ? Dimensions.minimumCellHeight : 0.0,
                textHeight + verticalMargins,
                imageHeight
            )
        }
    }

    static func actualSizeWithSpacing(measuring image: Property<ImageOrLabel>?,
                                     styleSheet: StyleSheet) -> (CGFloat, CGFloat) {
        return (
            Component.Toggle.imageWidthPlusSpacing(measuring: image, styleSheet: styleSheet),
            Component.Toggle.imageHeight(measuring: image, styleSheet: styleSheet)
        )
    }

    static func imageWidthPlusSpacing(measuring image: Property<ImageOrLabel>?,
                                      styleSheet: StyleSheet) -> CGFloat {
        let width: CGFloat

        if let size = styleSheet.imageOrLabel.fixedSize {
            width = size.width
        } else {
            switch image?.value {
            case let .image(image)?:
                width = image.size.width
                    + styleSheet.imageOrLabel.layoutMargins.left
                    + styleSheet.imageOrLabel.layoutMargins.right
            case let .text(text)?:
                width = (text as NSString)
                    .size(withAttributes: [.font: styleSheet.imageOrLabel.label.font])
                    .width
                    .rounded(.up)
            case .none?:
                width = 0
            case nil:
                return 0
            }
        }

        return min(width, Dimensions.maxImageViewWidth)
    }

    static func imageHeight(measuring image: Property<ImageOrLabel>?,
                                      styleSheet: StyleSheet) -> CGFloat {
        switch image?.value {
        case let .image(image)?:
        return styleSheet.imageOrLabel.fixedSize?.height ?? image.size.height
        case let .text(text)?:
            return styleSheet.text.height(of: text, fittingWidth: Dimensions.maxImageViewWidth)
        default:
            return 0
        }
    }
}

extension Component.Toggle {
    public final class View: BaseView {
        fileprivate let imageOrLabelView = ImageOrLabelView()
        fileprivate let toggle = UISwitch().width(50)
        fileprivate let textLabel = UILabel().with {
            $0.numberOfLines = 0
        }
        fileprivate let activityIndicator = UIActivityIndicatorView(style: .gray)
            .width(50)
            .with {
                $0.hidesWhenStopped = true
        }

        fileprivate var disposable: Disposable? {
            willSet { disposable?.dispose() }
        }

        fileprivate let contentView: UIStackView
        fileprivate var didChangeValue: ((Bool) -> Void)?
        fileprivate var isRefreshing: Bool = false {
            didSet {
                if isRefreshing {
                    contentView.removeArrangedSubview(toggle)
                    contentView.addArrangedSubview(activityIndicator)
                    activityIndicator.startAnimating()
                } else {
                    contentView.removeArrangedSubview(activityIndicator)
                    contentView.addArrangedSubview(toggle)
                    activityIndicator.stopAnimating()
                }
            }
        }

        public override init(frame: CGRect) {
            self.contentView = stack(
                .horizontal,
                spacing: 9,
                distribution: .fill,
                alignment: .center)(
                    imageOrLabelView,
                    textLabel
            )

            super.init(frame: frame)

            self.contentView
                .add(to: self)
                .pinEdges(to: layoutMarginsGuide)

            toggle.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc func valueChanged() {
            didChangeValue?(toggle.isOn)
        }
    }
}

extension Component.Toggle {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public let text: LabelStyleSheet
        public let imageOrLabel: ImageOrLabelView.StyleSheet

        public init(text: LabelStyleSheet, imageOrLabel: ImageOrLabelView.StyleSheet = .init()) {
            self.text = text
            self.imageOrLabel = imageOrLabel
        }

        public override func apply(to view: Component.Toggle.View) {
            super.apply(to: view)
            text.apply(to: view.textLabel)
            imageOrLabel.apply(to: view.imageOrLabelView)
        }
    }
}

extension Component.Toggle {
    enum Dimensions {
        static let toggleWidth: CGFloat = 50
        static let maxImageViewWidth: CGFloat = 100
        static let horizontalElementsSpacing: CGFloat = 9
        static let minimumCellHeight: CGFloat = 44
    }
}
