import ReactiveSwift

class TitledTextInputCell: UITableViewCell {

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

        textField.reactive.text
            <~ viewModel.text
                .producer
                .take(until: reactive.prepareForReuse)

        textField.reactive.isEnabled
            <~ viewModel.isInteractable
                .producer
                .take(until: reactive.prepareForReuse)

        viewModel.text
            <~ textField.reactive.continuousTextValues
                .skipNil()
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
