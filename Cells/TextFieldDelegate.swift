import UIKit
import ReactiveSwift
import enum Result.NoError

public final class TextFieldDelegate: NSObject, UITextFieldDelegate {

    private let _isFocused: MutableProperty<Bool> = MutableProperty(false)

    var isFocused: Property<Bool> {
        return Property(_isFocused)
            .skipRepeats()
    }

    private let (_lostFocusReason, _lostFocusReasonObserver) = Signal<LostFocusReason, NoError>.pipe()

    var lostFocusReason: Signal<LostFocusReason, NoError> {
        return _lostFocusReason
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _isFocused.value = false
        _lostFocusReasonObserver.send(value: .returnKey)
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        _isFocused.value = false
        _lostFocusReasonObserver.send(value: .other)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        _isFocused.value = true
    }
}
