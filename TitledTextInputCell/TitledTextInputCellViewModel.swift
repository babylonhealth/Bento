import ReactiveSwift
import enum Result.NoError

public final class TitledTextInputCellViewModel: FocusableFormComponent {

    private let visualDependencies: VisualDependenciesProtocol
    private let _isSecure: MutableProperty<Bool>
    let title: String
    let placeholder: String
    let text: ValidatingProperty<String, InvalidInput>
    let isEnabled: Property<Bool>
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let keyboardType: UIKeyboardType
    let width: Float
    var isSecure: Property<Bool> {
        return Property(_isSecure)
    }
    var peekAction: Action<Void, Void, NoError> {
        return Action { .run { self._isSecure.modify { isSecure in isSecure = !(isSecure) } } }
    }
    
    public init(title: String,
         placeholder: String,
         text: ValidatingProperty<String, InvalidInput>,
         isEnabled: Property<Bool> = Property(value: true),
         isSecure: Bool = false,
         autocapitalizationType: UITextAutocapitalizationType = .sentences,
         autocorrectionType: UITextAutocorrectionType = .`default`,
         keyboardType: UIKeyboardType = .`default`,
         visualDependencies: VisualDependenciesProtocol) {

        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.isEnabled = isEnabled
        self._isSecure = MutableProperty(isSecure)
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.keyboardType = keyboardType
        self.visualDependencies = visualDependencies
        self.width = isSecure ? 28 : 0
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }

    func applyInputStyle(to textField: UITextField) {
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
}
