import ReactiveSwift
import enum Result.NoError

public struct TitledTextInputCellViewModel: Focusable, Interactable, TextEditable {

    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let placeholder: String
    let text: ValidatingProperty<String, InvalidInput>
    let textFieldDelegate: TextFieldDelegate
    let isFocused = MutableProperty(false)
    let isInteractable = MutableProperty(true)
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let keyboardType: UIKeyboardType

    // TextEditable's properties
    let keyboardReturnKeyType: MutableProperty<UIReturnKeyType>

    var lostFocusReason: Signal<LostFocusReason, NoError> {
        return textFieldDelegate.lostFocusReason
    }

    public init(title: String,
         placeholder: String,
         text: ValidatingProperty<String, InvalidInput>,
         autocapitalizationType: UITextAutocapitalizationType = .sentences,
         autocorrectionType: UITextAutocorrectionType = .`default`,
         keyboardType: UIKeyboardType = .`default`,
         keyboardReturnKeyType: UIReturnKeyType = .next,
         visualDependencies: VisualDependenciesProtocol,
         textFieldDelegate: TextFieldDelegate = TextFieldDelegate()) {

        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.keyboardType = keyboardType
        self.keyboardReturnKeyType = MutableProperty(keyboardReturnKeyType)
        self.visualDependencies = visualDependencies
        self.textFieldDelegate = textFieldDelegate

        self.isFocused <~ textFieldDelegate.isFocused
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }

    func applyInputStyle(to textField: UITextField) {
        visualDependencies.styles.textFieldForm.apply(to: textField)
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.keyboardType = keyboardType
    }
}
