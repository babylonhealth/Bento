import UIKit
import Bento
import StyleSheets

public final class FocusTextField: UIView, UITextFieldDelegate {
    public let accessoryView = AccessoryView()
    public let textField = UITextField()

    var textWillChange: Optional<(TextChange) -> Bool> = nil
    var textDidChange: Optional<(String?) -> Void> = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    private func setupLayout() {
        stack(.horizontal, spacing: 16, distribution: .fill, alignment: .center)(
            textField, accessoryView
            )
            .add(to: self)
            .pinEdges(to: self)

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


extension FocusTextField: FocusableView {
    public func focus() {
        textField.becomeFirstResponder()
    }

    public func neighboringFocusEligibilityDidChange() {
        updateReturnKey()
        (textField.inputAccessoryView as? FocusToolbar)?.updateFocusEligibility(with: self)
        textField.reloadInputViews()
    }
}

extension FocusTextField {
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

extension FocusTextField {

    public enum Accessory {
        case icon(UIImage)
        case none

        public var toAccessoryViewAccessory: AccessoryView.Accessory {
            switch self {
            case let .icon(image):
                return .icon(image)
            case .none:
                return .none
            }
        }
    }
}

extension FocusTextField {
    public final class StyleSheet: ViewStyleSheet<FocusTextField> {
        public let text: TextFieldStylesheet

        public init(
            text: TextFieldStylesheet = TextFieldStylesheet()
            ) {
            self.text = text
        }

        public override func apply(to element: FocusTextField) {
            super.apply(to: element)
            text.apply(to: element.textField)
        }
    }
}
