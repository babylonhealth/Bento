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
            interactionBehavior: InteractionBehavior = .becomeFirstResponder,
            styleSheet: StyleSheet
        ) {
            self.configurator = { view in
                view.isLoading = isLoading
                view.button.isEnabled = isEnabled
                view.button.setTitle(title, for: .normal)
                view.didTap = didTap
                view.interactionBehavior = interactionBehavior
            }
            self.heightComputer = { width, inheritedMargins in
                let contentWidth = width
                    - max(styleSheet.layoutMargins.left, inheritedMargins.left)
                    - max(styleSheet.layoutMargins.right, inheritedMargins.right)
                    - styleSheet.button.contentEdgeInsets.horizontalTotal

                let titleHeight = styleSheet.button.height(of: title ?? "", fittingWidth: contentWidth)
                let imageHeight = styleSheet.button.image(for: .normal)?.size.height ?? 0

                return styleSheet.layoutMargins.verticalTotal
                    + max(
                        styleSheet.button.contentEdgeInsets.verticalTotal + max(titleHeight, imageHeight),
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

        public var button = Button(type: .system)

        private var leadingConstraint: NSLayoutConstraint?
        private var trailingConstraint: NSLayoutConstraint?
        private var centerXConstraint: NSLayoutConstraint?

        fileprivate var interactionBehavior: InteractionBehavior = .becomeFirstResponder

        fileprivate var buttonType: UIButton.ButtonType = .system {
            didSet {
                guard oldValue != buttonType else { return }

                activityIndicator.removeFromSuperview()
                button.removeFromSuperview()

                button = Button(type: buttonType)
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

                setupLayout()
            }
        }

        fileprivate var hugsContent: Bool = false {
            didSet {
                setupHorizontalConstraints()
            }
        }

        fileprivate var alignment: Alignment = .center {
            didSet {
                setupHorizontalConstraints()
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

            setupHorizontalConstraints()

            button.setContentHuggingPriority(.required, for: .vertical)

            activityIndicator
                .add(to: self)
                .pinCenter(to: button)

            if isLoading {
                activityIndicator.startAnimating()
            }
        }

        private func setupHorizontalConstraints() {
            centerXConstraint?.isActive = false
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = false

            centerXConstraint = button.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
            leadingConstraint = {
                switch (alignment, hugsContent) {
                case (.leading, _),
                     (.center, false):
                    return button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
                case (.trailing, _),
                     (.center, true):
                    return button.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor)
                }
            }()

            trailingConstraint = {
                switch (alignment, hugsContent) {
                case (.leading, _),
                     (.center, true):
                    return layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: button.trailingAnchor)
                case (.trailing, _),
                     (.center, false):
                    return layoutMarginsGuide.trailingAnchor.constraint(equalTo: button.trailingAnchor)
                }
            }()

            leadingConstraint?.isActive = true
            trailingConstraint?.isActive = true
            centerXConstraint?.isActive = (alignment == .center)
        }

        @objc private func buttonPressed() {
            if interactionBehavior.contains(.becomeFirstResponder) {
                becomeFirstResponder()
            }

            didTap?()
        }
    }
}

public extension Component.Button {
    public final class StyleSheet: InteractiveViewStyleSheet<View> {
        public let button: ButtonStyleSheet
        public let activityIndicator: ActivityIndicatorStyleSheet
        public var hugsContent: Bool
        public var alignment: Alignment
        public var autoRoundCorners: Bool
        public var buttonType: UIButton.ButtonType

        public init(
            button: ButtonStyleSheet,
            activityIndicator: ActivityIndicatorStyleSheet = .init(),
            hugsContent: Bool = false,
            alignment: Alignment = .center,
            autoRoundCorners: Bool = false,
            buttonType: UIButton.ButtonType = .system
        ) {
            self.button = button
            self.activityIndicator = activityIndicator
            self.hugsContent = hugsContent
            self.alignment = alignment
            self.autoRoundCorners = autoRoundCorners
            self.buttonType = buttonType
        }

        public override func apply(to element: Component.Button.View) {
            super.apply(to: element)
            element.buttonType = buttonType
            button.apply(to: element.button)
            activityIndicator.apply(to: element.activityIndicator)
            element.hugsContent = hugsContent
            element.alignment = alignment
            element.button.autoRoundCorners = autoRoundCorners
        }
    }

    public enum Alignment {
        case leading
        case trailing
        case center
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
