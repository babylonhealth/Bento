import ReactiveSwift

class TitledTextInputCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    private var viewModel: TitledTextInputCellViewModel!

    func setup(viewModel: TitledTextInputCellViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        viewModel.applyTitleStyle(to: titleLabel)

        textField.placeholder = viewModel.placeholder
        textField.delegate = viewModel.textFieldDelegate
        viewModel.applyInputStyle(to: textField)

        textField.reactive.text
            <~ viewModel.text
                .producer
                .take(until: reactive.prepareForReuse)

        textField.reactive.isEnabled
            <~ viewModel.isInteractable
                .producer
                .take(until: reactive.prepareForReuse)

        textField.reactive.returnKeyType
            <~ viewModel.keyboardReturnKeyType
                .producer
                .take(until: reactive.prepareForReuse)

        viewModel.isFocused
            .producer
            .skipRepeats()
            .filter { $0 }
            .observe(on: QueueScheduler.main) // ‼️ NOTE: This is really important to avoid deadlocks 💥
            .startWithValues { [weak self] _ in
                self?.textField.becomeFirstResponder()
            }

        viewModel.text
            <~ textField.reactive.continuousTextValues
                .skipNil()
                .take(until: reactive.prepareForReuse)
    }
}

extension TitledTextInputCell: NibLoadableCell {}
