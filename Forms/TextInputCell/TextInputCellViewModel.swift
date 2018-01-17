import ReactiveSwift
import Result

public final class TextInputCellViewModel: FocusableFormComponent {

    private let _isSecure: MutableProperty<Bool>
    private let _clearsOnBeginEditing: MutableProperty<Bool>

    let placeholder: String
    let text: ValidatingProperty<String, InvalidInput>
    let isEnabled: Property<Bool>
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let keyboardType: UIKeyboardType
    let visualDependencies: VisualDependenciesProtocol
    let selectionStyle: UITableViewCellSelectionStyle = .none
    let width: Float
    let editingDidEndAction: Action<String?, Void, NoError>?
    let icon: SignalProducer<UIImage, NoError>?
    let allowsYieldingOfFocus: Bool
    let deleteAction: Action<Void, Void, NoError>?

    var isSecure: Property<Bool> {
        return Property(_isSecure)
    }

    var clearsOnBeginEditing: Property<Bool> {
        return Property(_clearsOnBeginEditing)
    }

    var peekAction: Action<Void, Void, NoError> {
        return Action { .run { self._isSecure.modify { isSecure in isSecure = !(isSecure) } } }
    }

    public init(icon: SignalProducer<UIImage, NoError>? = nil,
                placeholder: String,
                text: ValidatingProperty<String, InvalidInput>,
                isEnabled: Property<Bool> = Property(value: true),
                isSecure: Bool,
                clearsOnBeginEditing: Bool = false,
                autocapitalizationType: UITextAutocapitalizationType = .sentences,
                autocorrectionType: UITextAutocorrectionType = .`default`,
                keyboardType: UIKeyboardType = .`default`,
                allowsYieldingOfFocus: Bool = true,
                editingDidEndAction: Action<String?, Void, NoError>? = nil,
                deleteAction: Action<Void, Void, NoError>? = nil,
                visualDependencies: VisualDependenciesProtocol) {
        self._isSecure = MutableProperty(isSecure)
        let clearsOnBeginEditingValue = isSecure ? true : clearsOnBeginEditing
        self._clearsOnBeginEditing = MutableProperty(clearsOnBeginEditingValue)
        self.placeholder = placeholder
        self.text = text
        self.isEnabled = isEnabled
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.keyboardType = keyboardType
        self.editingDidEndAction = editingDidEndAction
        self.icon = icon
        self.allowsYieldingOfFocus = allowsYieldingOfFocus
        self.deleteAction = deleteAction
        self.visualDependencies = visualDependencies

        self.width = isSecure ? 54 : 0
    }

    func applyStyle(to textField: UITextField) {
        visualDependencies.styles.textFieldForm.apply(to: textField)
        visualDependencies.styles.tintBrandColor.apply(to: textField)
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.keyboardType = keyboardType
    }

    func applyStyle(to button: UIButton) {
        button.tintColor = .clear
        button.setImage(visualDependencies.styles.formIcons.peekImage, for: .normal)
        button.setImage(visualDependencies.styles.formIcons.unPeekImage, for: .selected)
    }

    func applyBackgroundColor(to views: [UIView]) {
        visualDependencies.styles.backgroundCustomColor.apply(color: visualDependencies.styles.appColors.formTextFieldTextBackgroundColor, to: views)
    }
}
