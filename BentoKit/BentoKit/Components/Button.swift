import Bento
import StyleSheets
import UIKit

extension Component {
    public final class Button: AutoRenderable, HeightCustomizing {

        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        private let heightComputer: (CGFloat, UIEdgeInsets) -> CGFloat

        public init(
            title: String? = nil,
            isEnabled: Bool = true,
            isLoading: Bool = false,
            didTap: (() -> Void)? = nil,
            styleSheet: StyleSheet
        ) {
            self.configurator = { view in
                view.isLoading = isLoading
                view.button.isEnabled = isEnabled
                view.button.setTitle(title, for: .normal)
                view.didTap = didTap
            }
            self.heightComputer = { width, inheritedMargins in
                let contentWidth = width
                    - max(styleSheet.layoutMargins.left, inheritedMargins.left)
                    - max(styleSheet.layoutMargins.right, inheritedMargins.right)
                    - styleSheet.button.contentEdgeInsets.horizontalTotal

                return styleSheet.layoutMargins.verticalTotal
                    + max(
                        styleSheet.button.contentEdgeInsets.verticalTotal
                            + styleSheet.button.height(of: title ?? "", fittingWidth: contentWidth),
                        styleSheet.enforcesMinimumHeight ? 44.0 : 0.0
                    )
            }
            self.styleSheet = styleSheet
        }

        public func height(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }

        public func estimatedHeight(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }
    }
}

extension Component.Button {
    public final class View: InteractiveView {

        fileprivate let activityIndicator: UIActivityIndicatorView = {
            return UIActivityIndicatorView().with {
                $0.isHidden = true
                $0.hidesWhenStopped = true
            }
        }()

        public let button = Button(type: .system).with {
            $0.setContentHuggingPriority(.required, for: .vertical)
        }

        private lazy var huggingConstraints: [NSLayoutConstraint] = [
            button.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor)
                .withPriority(.defaultHigh),
            layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: button.trailingAnchor)
                .withPriority(.defaultHigh)
        ]

        private lazy var strictConstraints: [NSLayoutConstraint] = [
            button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
                .withPriority(.defaultHigh),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: button.trailingAnchor)
                .withPriority(.defaultHigh)
        ]

        fileprivate var hugsContent: Bool = false {
            didSet {
                huggingConstraints.forEach { $0.isActive = hugsContent }
                strictConstraints.forEach { $0.isActive = hugsContent == false }
            }
        }

        public var isLoading: Bool = false {
            didSet {
                isLoading
                    ? activityIndicator.startAnimating()
                    : activityIndicator.stopAnimating()

                button.isEnabled = isLoading == false
            }
        }

        public var didTap: (() -> Void)?

        public override init(frame: CGRect) {
            super.init(frame: frame)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            setupLayout()
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            button
                .add(to: self)
                .pinTop(to: layoutMarginsGuide)
                .pinBottom(to: layoutMarginsGuide)

            button.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
                .activated()
            strictConstraints.forEach { $0.isActive = true }

            activityIndicator
                .add(to: self)
                .pinCenter(to: button)
        }

        @objc private func buttonPressed() {
            becomeFirstResponder()
            didTap?()
        }
    }
}

public extension Component.Button {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public let button: ButtonStyleSheet
        public let activityIndicator: ActivityIndicatorStyleSheet
        public var hugsContent: Bool
        public var autoRoundCorners: Bool

        public init(button: ButtonStyleSheet, activityIndicator: ActivityIndicatorStyleSheet = .init(), hugsContent: Bool = false, autoRoundCorners: Bool = false) {
            self.button = button
            self.activityIndicator = activityIndicator
            self.hugsContent = hugsContent
            self.autoRoundCorners = autoRoundCorners
        }

        public override func apply(to element: Component.Button.View) {
            super.apply(to: element)
            button.apply(to: element.button)
            activityIndicator.apply(to: element.activityIndicator)
            element.hugsContent = hugsContent
            element.button.autoRoundCorners = autoRoundCorners
        }
    }
}

public class Button: UIButton {
    var autoRoundCorners: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = autoRoundCorners ? bounds.height * 0.5 : layer.cornerRadius
    }
}
