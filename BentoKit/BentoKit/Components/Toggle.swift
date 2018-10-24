import Bento
import StyleSheets

extension Component {
    public final class Toggle: AutoRenderable, HeightCustomizing {
        private let heightComputer: (CGFloat, UIEdgeInsets) -> CGFloat

        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

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
                    ? Dimensions.imageViewWidth + Dimensions.horizontalElementsSpacing
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
                    textHeight + verticalMargins
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
        fileprivate let imageView = UIImageView().width(32).height(32)
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

        public init(text: LabelStyleSheet) {
            self.text = text
        }

        public override func apply(to view: Component.Toggle.View) {
            super.apply(to: view)
            text.apply(to: view.textLabel)
        }
    }
}

extension Component.Toggle {
    enum Dimensions {
        static let toggleWidth: CGFloat = 50
        static let imageViewWidth: CGFloat = 32
        static let horizontalElementsSpacing: CGFloat = 9
        static let minimumCellHeight: CGFloat = 44
    }
}
