import ReactiveSwift
import enum Result.NoError

protocol Interactable {
	var isInteractable: MutableProperty<Bool> { get }
}

enum LostFocusReason {
    case returnKey
    case other
}

protocol Focusable {

	var isFocused: MutableProperty<Bool> { get }

    var lostFocusReason: Signal<LostFocusReason, NoError> { get }
}

protocol Selectable {
	var isSelected: Action<Void, Void, NoError> { get }
}

protocol TextEditable {

    var keyboardReturnKeyType: MutableProperty<UIReturnKeyType> { get }
}
