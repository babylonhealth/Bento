import ReactiveSwift
import enum Result.NoError

public final class PhoneInputCellViewModel: FocusableFormComponent {

    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let placeholder: String
    let countryCode: MutableProperty<String>
    let phoneNumber: MutableProperty<String>
    let isEnabled: Property<Bool>

    init(title: String,
         placeholder: String,
         countryCode: MutableProperty<String>,
         phoneNumber: MutableProperty<String>,
         isEnabled: Property<Bool>? = nil,
         visualDependencies: VisualDependenciesProtocol) {

        self.visualDependencies = visualDependencies
        self.title = title
        self.placeholder = placeholder
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.isEnabled = isEnabled ?? Property(value: true)
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }

    func applyInputStyle(to textField: UITextField) {
        visualDependencies.styles.textFieldForm.apply(to: textField)
    }
}
