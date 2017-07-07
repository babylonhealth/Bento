import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

extension TextInputCell: NibLoadableCell {}

final class TextInputCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var peekButton: UIButton!
    @IBOutlet weak var peekWidthConstraint: NSLayoutConstraint!

    private var viewModel: TextInputCellViewModel!
    internal weak var delegate: FocusableCellDelegate?

    private var isSecure: SignalProducer<Bool, NoError> {
        return viewModel.isSecure
            .producer
            .take(during: reactive.lifetime)
    }

    private var clearsOnBeginEditing: SignalProducer<Bool, NoError> {
        return viewModel.clearsOnBeginEditing
            .producer
            .take(during: reactive.lifetime)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    func setup(viewModel: TextInputCellViewModel) {
        self.viewModel = viewModel
        textField.placeholder = viewModel.placeholder

        textField.reactive.text
            <~ viewModel.text
                .producer
                .take(until: reactive.prepareForReuse)

        textField.reactive.isSecureTextEntry
            <~ isSecure
                .producer
                .take(until: reactive.prepareForReuse)

        textField.reactive.clearsOnBeginEditing
            <~ clearsOnBeginEditing
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

        peekButton.reactive.isSelected
            <~ isSecure
                .negate()
                .take(until: reactive.prepareForReuse)
        
        peekButton.reactive.pressed = CocoaAction(viewModel.peekAction)

        viewModel.applyStyle(to: textField)
        viewModel.applyStyle(to: peekButton)
        viewModel.applyBackgroundColor(to: [self, textField])

        self.selectionStyle = viewModel.selectionStyle
        self.peekWidthConstraint.constant = CGFloat(viewModel.width)
    }
}

extension TextInputCell: FocusableCell {
    func focus() {
        textField.becomeFirstResponder()
    }
}

extension TextInputCell: UITextFieldDelegate {
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
