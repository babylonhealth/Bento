import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

extension NoteInputCell: NibLoadableCell {}

final class NoteInputCell: FormCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addPhotosButton: UIButton!
    @IBOutlet weak var placeholder: UILabel!
    private var viewModel: NoteInputCellViewModel!
    internal weak var delegate: FocusableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }

    func setup(viewModel: NoteInputCellViewModel) {
        self.viewModel = viewModel
        placeholder.text = viewModel.placeholder

        let isEnabled = viewModel.isEnabled.and(isFormEnabled)

        isEnabled.producer
            .take(until: reactive.prepareForReuse)
            .startWithSignal { isEnabled, _ in
                textView.reactive.isUserInteractionEnabled <~ isEnabled
                addPhotosButton.reactive.isEnabled <~ isEnabled
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
        viewModel.text <~ textView.reactive.continuousTextValues
            .filterMap { isEnabled.value ? $0 : nil }
            .take(until: reactive.prepareForReuse)

        textView.reactive.text <~ viewModel.text.producer
            .take(until: reactive.prepareForReuse)

        textView.reactive.continuousTextValues
            .observe(on: UIScheduler())
            .observeValues { value in
                self.placeholder.isHidden = (value != nil && value!.isEmpty == false)
        }

        addPhotosButton.reactive.pressed = CocoaAction(viewModel.addAction)

        viewModel.applyStyle(to: textView)
        viewModel.applyStyle(to: placeholder)
        viewModel.applyStyle(to: addPhotosButton)
        viewModel.applyBackgroundColor(to: [self, textView])

        self.selectionStyle = viewModel.selectionStyle
    }
}

extension NoteInputCell: FocusableCell {
    func focus() {
        textView.becomeFirstResponder()
    }
}

extension NoteInputCell: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let hasSuccessor = delegate?.focusableCellHasSuccessor(self) ?? false        
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.focusableCellWillResignFirstResponder(self) ?? true
    }
}