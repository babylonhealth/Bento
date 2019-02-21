import Bento
import StyleSheets
import Foundation

extension Component {
    public final class TextInput: AutoRenderable, Focusable {

        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet
        public let focusEligibility: FocusEligibility

        public init(
            title: String? = nil,
            placeholder: String? = nil,
            text: TextValue? = nil,
            keyboardType: UIKeyboardType = .default,
            isEnabled: Bool = true,
            accessory: FocusTextField.Accessory = .none,
            textWillChange: Optional<(FocusTextField.TextChange) -> Bool> = nil,
            textDidChange: Optional<(String?) -> Void> = nil,
            didTapAccessory: Optional<() -> Void> = nil,
            styleSheet: StyleSheet
        ) {
            self.configurator = { view in
                view.titleLabel.text = title
                view.titleLabel.isHidden = title?.isEmpty ?? true
                view.textField.textField.placeholder = placeholder
                view.textField.textField.keyboardType = keyboardType
                view.textField.textField.isEnabled = isEnabled
                text?.apply(to: view.textField.textField)
                view.textField.accessoryView.accessory = accessory.toAccessoryViewAccessory
                view.textField.accessoryView.didTap = didTapAccessory
                view.textField.textWillChange = textWillChange
                view.textField.textDidChange = textDidChange
            }

            let isNotEmpty = text?.isEmpty ?? false
            self.focusEligibility = isNotEmpty ? .eligible(.populated) : .eligible(.empty)
            self.styleSheet = styleSheet
        }
    }
}

extension Component.TextInput {
    public final class View: BaseView, UITextFieldDelegate {

        public enum TitleStyle {
            case fit
            case fillProportionally(CGFloat)
        }

        fileprivate let contentView = UIView()

        private var titleLabelWidthConstraint: NSLayoutConstraint? {
            willSet { titleLabelWidthConstraint?.isActive = false }
            didSet { titleLabelWidthConstraint?.isActive = true }
        }

        fileprivate let titleLabel = UILabel()
        fileprivate let textField = FocusTextField()

        fileprivate var titleStyle: TitleStyle = .fit {
            didSet {
                switch titleStyle {
                case .fit:
                    titleLabelWidthConstraint = nil
                case let .fillProportionally(proportion):
                    titleLabelWidthConstraint = titleLabel.widthAnchor.constraint(
                        equalTo: widthAnchor,
                        multiplier: proportion
                    )
                    .withPriority(.required)
                }
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }

        private func setupLayout() {
            contentView
                .add(to: self)
                .pinEdges(to: layoutMarginsGuide)

            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            stack(.horizontal, spacing: 16.0, distribution: .fill, alignment: .center)(
                titleLabel, textField
            )
            .add(to: contentView)
            .pinEdges(to: contentView.layoutMarginsGuide)
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Component.TextInput {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public var titleStyle: View.TitleStyle
        public let title: LabelStyleSheet
        public let text: FocusTextField.StyleSheet
        public let content: ViewStyleSheet<UIView>

        public init(
            titleStyle: View.TitleStyle = .fillProportionally(0.25),
            title: LabelStyleSheet = LabelStyleSheet(
                font: UIFont.preferredFont(forTextStyle: .body),
                textAlignment: .leading
            ),
            text: FocusTextField.StyleSheet = FocusTextField.StyleSheet(),
            content: ViewStyleSheet<UIView> = ViewStyleSheet(layoutMargins: .zero)
        ) {
            self.titleStyle = titleStyle
            self.title = title
            self.text = text
            self.content = content
        }

        public override func apply(to element: Component.TextInput.View) {
            super.apply(to: element)
            element.titleStyle = titleStyle
            title.apply(to: element.titleLabel)
            text.apply(to: element.textField)
            content.apply(to: element.contentView)
        }
    }
}
