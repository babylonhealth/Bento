import ReactiveSwift
import enum Result.NoError

public struct PhoneInputCellViewModel: Interactable, FocusableFormComponent {

    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let placeholder: String
    let countryCode: MutableProperty<String>
    let phoneNumber: MutableProperty<String>
    let isInteractable = MutableProperty(true)

    init(title: String,
         placeholder: String,
         countryCode: MutableProperty<String>,
         phoneNumber: MutableProperty<String>,
         visualDependencies: VisualDependenciesProtocol) {

        self.visualDependencies = visualDependencies
        self.title = title
        self.placeholder = placeholder
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }

    func applyInputStyle(to textField: UITextField) {
        visualDependencies.styles.textFieldForm.apply(to: textField)
    }
}
