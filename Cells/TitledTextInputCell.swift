import ReactiveSwift

class TitledTextInputCell: FormCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    private var viewModel: TitledTextInputCellViewModel!
    internal weak var delegate: FocusableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    func setup(viewModel: TitledTextInputCellViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        viewModel.applyTitleStyle(to: titleLabel)

        textField.placeholder = viewModel.placeholder
        viewModel.applyInputStyle(to: textField)

        textField.reactive.text <~ viewModel.text.producer
            .take(until: reactive.prepareForReuse)

        let isEnabled = viewModel.isEnabled.and(isFormEnabled)
        textField.reactive.isEnabled <~ isEnabled.producer
            .take(until: reactive.prepareForReuse)

        // `continuousTextValues` yields the current text for all text field control
        // events. This may lead to deadlock if:
        //
        // 1. `isFormEnabled` is derived from `isExecuting` of an `Action`; and
        // 2. `viewModel.text` feeds into the `Action` as its state.
        //
        // So we filter any value being yielded after the form is disabled.
        viewModel.text <~ textField.reactive.continuousTextValues
            .filterMap { isEnabled.value ? $0 : nil }
            .take(until: reactive.prepareForReuse)
    }
}

extension TitledTextInputCell: FocusableCell {
    func focus() {
        textField.becomeFirstResponder()
    }
}

extension TitledTextInputCell: UITextFieldDelegate {
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

extension TitledTextInputCell: NibLoadableCell {}
