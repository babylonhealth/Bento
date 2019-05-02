
extension Component {
    public final class Toggle: AutoRenderable, HeightCustomizing {
        private let heightComputer: (CGFloat, UIEdgeInsets) -> CGFloat

        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        /// Creates Component.Toggle
        /// - parameter title: Name/label/title of a row which is displayed on the left side.
        /// - parameter attributedTitle: The same as `title` but allows for using attributed text.
        /// - parameter image: Icon displayed on the left side of the row.
        /// - parameter isOn: Indicates if the toggle shows true or false.
        /// - parameter isEnabled: Indicates if user can change value of the toggle.
        /// - parameter isRefreshing: If `true` it displays `UIActivityIndicator` instead of the switch view.
        /// - parameter animateValueChange: Indicates if should animate setting of the `isOn` value.
        /// - parameter styleSheet: StyleSheet with styling.
        /// - parameter didChangeValue: Closure which notifies about true/false change.
        public init(
            title: String,
            attributedTitle: NSAttributedString? = nil,
            image: UIImage? = nil,
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

                view.imageView.image = image
                view.imageView.isHidden = (image == nil)
                view.isRefreshing = isRefreshing
            }

            self.heightComputer = { width, inheritedMargins in
                let verticalMargins = styleSheet.layoutMargins.verticalTotal
                let imageWidth: CGFloat = image != nil
                    ? (image?.size.width ?? 0) + Dimensions.horizontalElementsSpacing
                    : 0.0

                let textBoundWidth = width
                    - max(styleSheet.layoutMargins.left, inheritedMargins.left)
                    - max(styleSheet.layoutMargins.right, inheritedMargins.right)
                    - Dimensions.toggleWidth
                    - Dimensions.horizontalElementsSpacing
                    - imageWidth

                let textHeight = styleSheet.text.height(of: title, fittingWidth: textBoundWidth)

                return max(
                    styleSheet.enforcesMinimumHeight ? Dimensions.minimumCellHeight : 0.0,
                    textHeight + verticalMargins,
                    image?.size.height ?? 0
                )
            }
        }

        public func estimatedHeight(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }

        public func height(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }
    }
}

extension Component.Toggle {
    public final class View: BaseView {
        fileprivate let imageView = UIImageView()
        fileprivate let toggle = UISwitch().width(50)
        fileprivate let textLabel = UILabel().with {
            $0.numberOfLines = 0
        }
        fileprivate let activityIndicator = UIActivityIndicatorView(style: .gray)
            .width(50)
            .with {
                $0.hidesWhenStopped = true
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
                    imageView,
                    textLabel
            )

            imageView.setContentHuggingPriority(.required, for: .horizontal)
            imageView.setContentHuggingPriority(.required, for: .vertical)
            imageView.setContentCompressionResistancePriority(.cellRequired, for: .vertical)
            imageView.setContentCompressionResistancePriority(.required, for: .horizontal)

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
        public let spacing: CGFloat

        public init(text: LabelStyleSheet, spacing: CGFloat = 9) {
            self.text = text
            self.spacing = spacing
        }

        public override func apply(to view: Component.Toggle.View) {
            super.apply(to: view)
            text.apply(to: view.textLabel)
            view.contentView.spacing = spacing
        }
    }
}

extension Component.Toggle {
    enum Dimensions {
        static let toggleWidth: CGFloat = 50
        static let horizontalElementsSpacing: CGFloat = 9
        static let minimumCellHeight: CGFloat = 44
    }
}
