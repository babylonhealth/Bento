import ReactiveSwift
import ReactiveCocoa
import UIKit

class PhoneInputCell: UITableViewCell {

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

        countryCodeTextField.reactive.text
            <~ viewModel.countryCode
                .producer
                .take(until: reactive.prepareForReuse)

        countryCodeTextField.reactive.isEnabled
            <~ viewModel.isInteractable
                .producer
                .take(until: reactive.prepareForReuse)

        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.placeholder = viewModel.placeholder
        viewModel.applyInputStyle(to: phoneNumberTextField)

        phoneNumberTextField.reactive.text
            <~ viewModel.phoneNumber
                .producer
                .take(until: reactive.prepareForReuse)

        phoneNumberTextField.reactive.isEnabled
            <~ viewModel.isInteractable
                .producer
                .take(until: reactive.prepareForReuse)

        viewModel.countryCode <~ countryCodeTextField.reactive.continuousTextValues
            .skipNil()
            .take(until: reactive.prepareForReuse)

        viewModel.phoneNumber <~ phoneNumberTextField.reactive.continuousTextValues
            .skipNil()
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
