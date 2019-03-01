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
            accessory: Accessory = .none,
            textWillChange: Optional<(TextChange) -> Bool> = nil,
            textDidChange: Optional<(String?) -> Void> = nil,
            didTapAccessory: Optional<() -> Void> = nil,
            styleSheet: StyleSheet
        ) {
            self.configurator = { view in
                view.titleLabel.text = title
                view.titleLabel.isHidden = title?.isEmpty ?? true
                view.textField.placeholder = placeholder
                view.textField.keyboardType = keyboardType
                view.textField.isEnabled = isEnabled
                text?.apply(to: view.textField)
                view.accessoryView.accessory = accessory.toAccessoryViewAccessory
                view.accessoryView.didTap = didTapAccessory
                view.textWillChange = textWillChange
                view.textDidChange = textDidChange
            }

            let isNotEmpty = text?.isEmpty ?? false
            self.focusEligibility = isNotEmpty ? .eligible(.populated) : .eligible(.empty)
            self.styleSheet = styleSheet
        }
    }
}

extension Component.TextInput {
    public struct TextChange {
        public let current: String?
        public let change: String
        public let range: NSRange

        public var result: String {
            guard let current = self.current,
                  let range = Range(range, in: current)
                else { return "" }

            return current.replacingCharacters(in: range, with: change)
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
        fileprivate let textField = UITextField()
        fileprivate let accessoryView = AccessoryView()

        fileprivate var titleStyle: TitleStyle = .fit {
            didSet {
                switch titleStyle {
                case .fit:
                    titleLabelWidthConstraint = nil
                case let .fillProportionally(proportion):
                    titleLabelWidthConstraint = titleLabel.widthAnchor.constraint(
                        equalTo: contentView.widthAnchor,
                        multiplier: proportion
                    )
                    .withPriority(.required)
                }
            }
        }

        var textWillChange: Optional<(TextChange) -> Bool> = nil
        var textDidChange: Optional<(String?) -> Void> = nil

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }

        private func setupLayout() {
            preservesSuperviewLayoutMargins = true

            contentView
                .add(to: self)
                .pinEdges(to: layoutMarginsGuide)

            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            stack(.horizontal, spacing: 16.0, distribution: .fill, alignment: .center)(
                titleLabel, textField, accessoryView
            )
            .add(to: contentView)
            .pinEdges(to: contentView.layoutMarginsGuide)

            textField.addTarget(self, action: #selector(textDidChangeOn(_:)), for: UIControl.Event.editingChanged)
            textField.delegate = self
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc private func textDidChangeOn(_ textField: UITextField) {
            self.textDidChange?(textField.text)
        }

        @objc public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return textWillChange?(
                .init(current: textField.text, change: string, range: range)
                ) ?? true
        }

        @objc public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            withFocusCoordinator { coordinator in
                if !coordinator.move(.backward) {
                    textField.resignFirstResponder()
                }
            }

            return false
        }

        @objc public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            updateReturnKey()
            textField.inputAccessoryView = FocusToolbar(view: self)
            return true
        }

        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            textField.inputAccessoryView = nil
        }

        private func updateReturnKey() {
            withFocusCoordinator { coordinator in
                let usesNextKey = coordinator.canMove(.backward)
                textField.returnKeyType = usesNextKey ? .next : .done
            }
        }
    }
}

extension Component.TextInput.View: FocusableView {
    public func focus() {
        textField.becomeFirstResponder()
    }

    public func neighboringFocusEligibilityDidChange() {
        updateReturnKey()
        (textField.inputAccessoryView as? FocusToolbar)?.updateFocusEligibility(with: self)
        textField.reloadInputViews()
    }
}

extension Component.TextInput {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public var titleStyle: View.TitleStyle
        public let title: LabelStyleSheet
        public let text: TextFieldStylesheet
        public let content: ViewStyleSheet<UIView>

        public init(
            titleStyle: View.TitleStyle = .fillProportionally(0.25),
            title: LabelStyleSheet = LabelStyleSheet(
                font: UIFont.preferredFont(forTextStyle: .body),
                textAlignment: .leading
            ),
            text: TextFieldStylesheet = TextFieldStylesheet(),
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

extension Component.TextInput {

    public enum Accessory {
        case icon(UIImage)
        case none

        fileprivate var toAccessoryViewAccessory: AccessoryView.Accessory {
            switch self {
            case let .icon(image):
                return .icon(image)
            case .none:
                return .none
            }
        }
    }
}
