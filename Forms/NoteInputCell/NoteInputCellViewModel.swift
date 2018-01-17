import ReactiveSwift
import Result

public final class NoteInputCellViewModel: FocusableFormComponent {
    let placeholder: String?
    let text: ValidatingProperty<String, InvalidInput>
    let isEnabled: Property<Bool>
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let keyboardType: UIKeyboardType
    let visualDependencies: VisualDependenciesProtocol
    let selectionStyle: UITableViewCellSelectionStyle = .none

    let addPhotosAction: Action<Void, Void, NoError>?

    public init(placeholder: String? = nil,
                text: ValidatingProperty<String, InvalidInput>,
                isEnabled: Property<Bool> = Property(value: true),
                addPhotosAction: Action<Void, Void, NoError>? = nil,
                autocapitalizationType: UITextAutocapitalizationType = .sentences,
                autocorrectionType: UITextAutocorrectionType = .`default`,
                keyboardType: UIKeyboardType = .`default`,
                visualDependencies: VisualDependenciesProtocol) {

        self.placeholder = placeholder
        self.text = text
        self.isEnabled = isEnabled
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.keyboardType = keyboardType
        self.visualDependencies = visualDependencies
        self.addPhotosAction = addPhotosAction
    }

    func applyStyle(to label: UILabel) {
        visualDependencies.styles.customPlaceholder.apply(to: label)
    }

    func applyStyle(to textView: UITextView) {
        visualDependencies.styles.textViewForm.apply(to: textView)
        visualDependencies.styles.tintBrandColor.apply(to: textView)
        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType
        textView.keyboardType = keyboardType
    }

    func applyStyle(to button: UIButton) {
        button.setImage(visualDependencies.styles.formIcons.cameraImage, for: .normal)
    }

    func applyBackgroundColor(to views: [UIView]) {
        visualDependencies.styles.backgroundCustomColor.apply(color: visualDependencies.styles.appColors.formTextFieldTextBackgroundColor, to: views)
    }
}
