import ReactiveSwift
import Result

struct TextInputCellViewModel: Focusable, Interactable, TextEditable {

    private let _isSecure: MutableProperty<Bool>
    private let _clearsOnBeginEditing: MutableProperty<Bool>

    let placeholder: String
    let text: ValidatingProperty<String, InvalidInput>
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let keyboardType: UIKeyboardType
    let visualDependencies: VisualDependenciesProtocol
    let contentDependencies: ContentDependenciesProtocol?
    let textFieldDelegate: TextFieldDelegate
    let isFocused = MutableProperty(false)
    let isInteractable = MutableProperty(true)
    let selectionStyle: UITableViewCellSelectionStyle = .none
    let width: Float

    // TextEditable's properties
    let keyboardReturnKeyType: MutableProperty<UIReturnKeyType>

    var isSecure: Property<Bool> {
        return Property(_isSecure)
    }

    var clearsOnBeginEditing: Property<Bool> {
        return Property(_clearsOnBeginEditing)
    }

    var lostFocusReason: Signal<LostFocusReason, NoError> {
        return textFieldDelegate.lostFocusReason
    }

    var peekAction: Action<Void, Void, NoError> {
        return Action { .run { self._isSecure.modify { isSecure in isSecure = !(isSecure) } } }
    }

    init(placeholder: String,
         text: ValidatingProperty<String, InvalidInput>,
         isSecure: Bool,
         clearsOnBeginEditing: Bool = false,
         autocapitalizationType: UITextAutocapitalizationType = .sentences,
         autocorrectionType: UITextAutocorrectionType = .`default`,
         keyboardType: UIKeyboardType = .`default`,
         keyboardReturnKeyType: UIReturnKeyType = .next,
         visualDependencies: VisualDependenciesProtocol,
         contentDependencies: ContentDependenciesProtocol? = nil,
         textFieldDelegate: TextFieldDelegate = TextFieldDelegate()) {
        self._isSecure = MutableProperty(isSecure)
        let clearsOnBeginEditingValue = isSecure ? true : clearsOnBeginEditing
        self._clearsOnBeginEditing = MutableProperty(clearsOnBeginEditingValue)
        self.placeholder = placeholder
        self.text = text
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.keyboardType = keyboardType
        self.keyboardReturnKeyType = MutableProperty(keyboardReturnKeyType)
        self.visualDependencies = visualDependencies
        self.contentDependencies = contentDependencies
        self.textFieldDelegate = textFieldDelegate

        self.isFocused <~ textFieldDelegate.isFocused
        self.width = isSecure ? 54 : 0
    }

    func applyStyle(to textField: UITextField) {
        visualDependencies.styles.textFieldForm.apply(to: textField)
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.keyboardType = keyboardType
    }

    func applyStyle(to button: UIButton) {
        button.tintColor = .clear
        button.setImage(contentDependencies?.featureContent.formContent.peekImage, for: .normal)
        button.setImage(contentDependencies?.featureContent.formContent.unPeekImage, for: .selected)
    }

    func applyBackgroundColor(to views: [UIView]) {
        visualDependencies.styles.backgroundCustomColor.apply(color: visualDependencies.styles.appColors.formTextFieldTextBackgroundColor, to: views)
    }
}
