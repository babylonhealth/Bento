import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

extension TextInputCell: NibLoadableCell {}

final class TextInputCell: FormItemCell {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var peekButton: UIButton!
    @IBOutlet weak var peekWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var iconVerticalMarginConstraints: [NSLayoutConstraint]!
    @IBOutlet var textViewLeadingConstraint: NSLayoutConstraint!
    
    fileprivate var viewModel: TextInputCellViewModel!
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

        // FIXME: Remove workaround in ReactiveSwift 2.0.
        //
        // `continuousTextValues` yields the current text for all text field control
        // events. This may lead to deadlock in `Action` internally, if:
        //
        // 1. `isFormEnabled` is derived from `isExecuting` of an `Action`; and
        // 2. `viewModel.text` feeds into the `Action` as its state.
        //
        // So we filter any value being yielded after the form is disabled.
        //
        // This has been fixed in RAS 2.0.
        // https://github.com/ReactiveCocoa/ReactiveSwift/pull/400
        // https://github.com/ReactiveCocoa/ReactiveSwift/pull/481
        viewModel.text <~ textField.reactive.continuousTextValues
            .filterMap { isEnabled.value ? $0 : nil }
            .take(until: reactive.prepareForReuse)

        if let action = viewModel.editingDidEndAction {
            action <~ textField.reactive.textValues
                .take(until: reactive.prepareForReuse)
        }

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

        var activatingConstraints: [NSLayoutConstraint] = []
        var deactivatingConstraints: [NSLayoutConstraint] = []

        if let icon = viewModel.icon {
            activatingConstraints.append(iconWidthConstraint)
            activatingConstraints.append(contentsOf: iconVerticalMarginConstraints)

            iconView.layer.cornerRadius = iconWidthConstraint.constant / 2.0
            textViewLeadingConstraint.constant = 60
            iconView.isHidden = false
            iconView.contentMode = .scaleAspectFit
            iconView.reactive.image <~ icon
                .observe(on: UIScheduler())
                .take(until: reactive.prepareForReuse)
        } else {
            deactivatingConstraints.append(iconWidthConstraint)
            deactivatingConstraints.append(contentsOf: iconVerticalMarginConstraints)

            iconView.layer.cornerRadius = 0.0
            iconView.contentMode = .center
            iconView.isHidden = true

            textViewLeadingConstraint.constant = 0
        }

        NSLayoutConstraint.deactivate(deactivatingConstraints)
        NSLayoutConstraint.activate(activatingConstraints)
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
        textField.returnKeyType = hasSuccessor && viewModel.allowsYieldingOfFocus ? .next : .done
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.focusableCellWillResignFirstResponder(self) ?? true
    }
}
