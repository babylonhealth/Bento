import UIKit
import ReactiveSwift
import enum Result.NoError

final class TextFieldDelegate: NSObject, UITextFieldDelegate {

    private let _isFocused: MutableProperty<Bool> = MutableProperty(false)

    var isFocused: Property<Bool> {
        return Property(_isFocused)
            .skipRepeats()
    }

    private let (_lostFocusReason, _lostFocusReasonObserver) = Signal<LostFocusReason, NoError>.pipe()

    var lostFocusReason: Signal<LostFocusReason, NoError> {
        return _lostFocusReason
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _isFocused.value = false
        _lostFocusReasonObserver.send(value: .returnKey)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        _isFocused.value = false
        _lostFocusReasonObserver.send(value: .other)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        _isFocused.value = true
    }
}
