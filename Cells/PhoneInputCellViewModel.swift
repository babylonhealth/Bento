import ReactiveSwift
import enum Result.NoError

public struct PhoneInputCellViewModel: Focusable, Interactable, TextEditable {

    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let placeholder: String
    let countryCode: MutableProperty<String>
    let phoneNumber: MutableProperty<String>
    let textFieldDelegate: TextFieldDelegate
    let isFocused = MutableProperty(false)
    let isInteractable = MutableProperty(true)

    // TextEditable's properties
    let keyboardReturnKeyType: MutableProperty<UIReturnKeyType>

    var lostFocusReason: Signal<LostFocusReason, NoError> {
        return textFieldDelegate.lostFocusReason
    }

    init(title: String,
         placeholder: String,
         countryCode: MutableProperty<String>,
         phoneNumber: MutableProperty<String>,
         keyboardReturnKeyType: UIReturnKeyType = .next,
         visualDependencies: VisualDependenciesProtocol,
         textFieldDelegate: TextFieldDelegate = TextFieldDelegate()) {

        self.visualDependencies = visualDependencies
        self.title = title
        self.placeholder = placeholder
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.keyboardReturnKeyType = MutableProperty(keyboardReturnKeyType)
        self.textFieldDelegate = textFieldDelegate

        self.isFocused <~ textFieldDelegate.isFocused
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }

    func applyInputStyle(to textField: UITextField) {
        visualDependencies.styles.textFieldForm.apply(to: textField)
    }
}
