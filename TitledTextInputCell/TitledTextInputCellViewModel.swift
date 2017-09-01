import ReactiveSwift
import enum Result.NoError

public final class TitledTextInputCellViewModel: FocusableFormComponent {

    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let placeholder: String
    let text: ValidatingProperty<String, InvalidInput>
    let isEnabled: Property<Bool>
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let keyboardType: UIKeyboardType

    public init(title: String,
         placeholder: String,
         text: ValidatingProperty<String, InvalidInput>,
         isEnabled: Property<Bool> = Property(value: true),
         autocapitalizationType: UITextAutocapitalizationType = .sentences,
         autocorrectionType: UITextAutocorrectionType = .`default`,
         keyboardType: UIKeyboardType = .`default`,
         visualDependencies: VisualDependenciesProtocol) {

        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.isEnabled = isEnabled
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.keyboardType = keyboardType
        self.visualDependencies = visualDependencies
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
}
