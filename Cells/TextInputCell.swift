import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

extension TextInputCell: NibLoadableCell {}

final class TextInputCell: FormCell {

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

        let isEnabled = viewModel.isEnabled.and(isFormEnabled)

        isEnabled.producer
            .take(until: reactive.prepareForReuse)
            .startWithSignal { isEnabled, _ in
                textField.reactive.isEnabled <~ isEnabled
                peekButton.reactive.isEnabled <~ isEnabled
            }

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

        textField.reactive.text <~ viewModel.text.producer
            .take(until: reactive.prepareForReuse)

        textField.reactive.isSecureTextEntry <~ isSecure.producer
            .take(until: reactive.prepareForReuse)

        textField.reactive.clearsOnBeginEditing <~ clearsOnBeginEditing.producer
            .take(until: reactive.prepareForReuse)

        peekButton.reactive.isSelected <~ isSecure.negate()
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
        return delegate?.focusableCellWillResignFirstResponder(self) ?? true
    }
}
