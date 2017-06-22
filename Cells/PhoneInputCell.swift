import ReactiveSwift
import ReactiveCocoa
import UIKit

class PhoneInputCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    private var viewModel: PhoneInputCellViewModel!

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
        phoneNumberTextField.delegate = viewModel.textFieldDelegate
        viewModel.applyInputStyle(to: phoneNumberTextField)

        phoneNumberTextField.reactive.text
            <~ viewModel.phoneNumber
                .producer
                .take(until: reactive.prepareForReuse)

        phoneNumberTextField.reactive.isEnabled
            <~ viewModel.isInteractable
                .producer
                .take(until: reactive.prepareForReuse)

        phoneNumberTextField.reactive.returnKeyType
            <~ viewModel.keyboardReturnKeyType
                .producer
                .take(until: reactive.prepareForReuse)

        viewModel.isFocused
            .producer
            .filter { $0 }
            .skipRepeats()
            .observe(on: QueueScheduler.main) // ‼️ NOTE: This is really important to avoid deadlocks 💥
            .startWithValues { [weak self] _ in
                self?.phoneNumberTextField.becomeFirstResponder()
            }

        viewModel.countryCode <~ countryCodeTextField.reactive.continuousTextValues
            .skipNil()
            .take(until: reactive.prepareForReuse)

        viewModel.phoneNumber <~ phoneNumberTextField.reactive.continuousTextValues
            .skipNil()
            .take(until: reactive.prepareForReuse)
    }
}

extension PhoneInputCell: NibLoadableCell {}
