import ReactiveSwift
import ReactiveCocoa
import UIKit

class PhoneInputCell: FormCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    private var viewModel: PhoneInputCellViewModel!
    internal weak var delegate: FocusableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        phoneNumberTextField.delegate = self
    }

    func setup(viewModel: PhoneInputCellViewModel) {
        self.viewModel = viewModel

        titleLabel.text = viewModel.title
        viewModel.applyTitleStyle(to: titleLabel)
        viewModel.applyInputStyle(to: countryCodeTextField)

        let isEnabled = viewModel.isEnabled.and(isFormEnabled)

        isEnabled.producer
            .take(until: reactive.prepareForReuse)
            .startWithSignal { isEnabled, _ in
                phoneNumberTextField.reactive.isEnabled <~ isEnabled
                countryCodeTextField.reactive.isEnabled <~ isEnabled
            }

        // `continuousTextValues` yields the current text for all text field control
        // events. This may lead to deadlock if:
        //
        // 1. `isFormEnabled` is derived from `isExecuting` of an `Action`; and
        // 2. `viewModel.text` feeds into the `Action` as its state.
        //
        // So we filter any value being yielded after the form is disabled.
        viewModel.countryCode <~ countryCodeTextField.reactive.continuousTextValues
            .filterMap { isEnabled.value ? $0 : nil }
            .take(until: reactive.prepareForReuse)

        viewModel.phoneNumber <~ phoneNumberTextField.reactive.continuousTextValues
            .filterMap { isEnabled.value ? $0 : nil }
            .take(until: reactive.prepareForReuse)

        countryCodeTextField.reactive.text
            <~ viewModel.countryCode
                .producer
                .take(until: reactive.prepareForReuse)

        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.placeholder = viewModel.placeholder
        viewModel.applyInputStyle(to: phoneNumberTextField)

        phoneNumberTextField.reactive.text
            <~ viewModel.phoneNumber
                .producer
                .take(until: reactive.prepareForReuse)
    }
}

extension PhoneInputCell: FocusableCell {
    func focus() {
        phoneNumberTextField.becomeFirstResponder()
    }
}

extension PhoneInputCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let hasSuccessor = delegate?.focusableCellHasSuccessor(self) ?? false
        textField.returnKeyType = hasSuccessor ? .next : .done
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let succeeds = delegate?.focusableCellShouldYieldFocus(self) ?? false
        return !succeeds
    }
}

extension PhoneInputCell: NibLoadableCell {}
