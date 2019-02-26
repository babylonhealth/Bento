import Bento
import StyleSheets
import UIKit

extension Component {
    public final class Description: AutoRenderable, HeightCustomizing {
        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet
        private let heightComputer: (CGFloat, UIEdgeInsets) -> CGFloat

        public init(text: String,
                    // TODO: [WLT] (10/2018) The image is passed here, at accessoryIcon, but can also be
                    // passed to the ButtonStyleSheet style sheet, and that's confusing. Moreover,
                    // passing it only to the style sheet has no effect in showing it because of
                    // the `view.accessoryButton.isHidden = accessoryIcon == nil` line below. So,
                    // I think we should have only one point of entry, namely, the style sheet.
                    // In other words, I think we should remove the `accessoryIcon` argument from
                    // this initialiser.
                    accessoryIcon: UIImage? = nil,
                    didTap: (() -> Void)? = nil,
                    didTapAccessoryButton: (() -> Void)? = nil,
                    interactionBehavior: InteractionBehavior = .becomeFirstResponder,
                    styleSheet: StyleSheet) {
            self.configurator = { view in
                view.textLabel.text = text
                view.interactionBehavior = interactionBehavior
                view.didTap = didTap
                view.didTapAccessoryButton = didTapAccessoryButton
                view.accessoryButton.isHidden = accessoryIcon == nil
                view.accessoryButton.isUserInteractionEnabled = didTapAccessoryButton != nil
                view.accessoryButton.setImage(accessoryIcon, for: .normal)
            }
            self.heightComputer = { width, inheritedMargins in
                let verticalMargins = styleSheet.layoutMargins.verticalTotal
                let textBoundWidth = width
                    - max(styleSheet.layoutMargins.left, inheritedMargins.left)
                    - max(styleSheet.layoutMargins.right, inheritedMargins.right)
                    - (accessoryIcon.map { $0.size.width + styleSheet.horizontalSpacing } ?? 0)
                let textHeight = styleSheet.text.height(of: text, fittingWidth: textBoundWidth)
                return max(
                    styleSheet.enforcesMinimumHeight ? 44.0 : 0.0,
                    max(textHeight, accessoryIcon?.size.height ?? 0.0) + verticalMargins
                )
            }
            self.styleSheet = styleSheet
        }

        public func estimatedHeight(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }

        public func height(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }
    }
}

extension Component.Description {
    public final class View: InteractiveView {
        fileprivate let textLabel = UILabel().with {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        fileprivate let accessoryButton = UIButton(type: .custom).with {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.cellRequired, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.addTarget(self, action: #selector(accessoryButtonPressed), for: .touchUpInside)
        }

        fileprivate var interactionBehavior: InteractionBehavior = .becomeFirstResponder

        fileprivate var didTap: (() -> Void)? {
            didSet {
                highlightingGesture.didTap = didTap.map(HighlightingGesture.TapAction.resign)
            }
        }

        fileprivate var stackView: UIStackView!
        fileprivate var didTapAccessoryButton: (() -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            stackView = stack(.horizontal, distribution: .fill, alignment: .center)(
                textLabel,
                accessoryButton
            )

            stackView
                .add(to: self)
                .pinEdges(to: layoutMarginsGuide)
        }

        @objc private func accessoryButtonPressed() {
            if interactionBehavior.contains(.becomeFirstResponder) {
                becomeFirstResponder()
            }

            didTapAccessoryButton?()
        }
    }
}

extension Component.Description {

    public final class StyleSheet: BaseViewStyleSheet<View> {
        public let text: LabelStyleSheet
        public let accessoryButton: ButtonStyleSheet
        public var horizontalSpacing: CGFloat

        public init(
            text: LabelStyleSheet = LabelStyleSheet(font: UIFont.preferredFont(forTextStyle: .body)),
            accessoryButton: ButtonStyleSheet = ButtonStyleSheet(),
            horizontalSpacing: CGFloat = 8.0,
            enforcesMinimumHeight: Bool = false
        ) {
            self.text = text
            self.accessoryButton = accessoryButton
            self.horizontalSpacing = horizontalSpacing
            super.init(enforcesMinimumHeight: enforcesMinimumHeight)
        }

        public override func apply(to view: Component.Description.View) {
            super.apply(to: view)
            text.apply(to: view.textLabel)
            accessoryButton.apply(to: view.accessoryButton)
            view.stackView.spacing = horizontalSpacing
        }
    }
}
