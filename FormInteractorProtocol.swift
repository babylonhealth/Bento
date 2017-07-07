import ReactiveSwift
import enum Result.NoError

protocol Interactable {
	var isInteractable: MutableProperty<Bool> { get }
}

public protocol FocusableCellDelegate: class {
    /// Whether `cell` has a succeeding `FocusableCell`.
    ///
    /// - note:  The cell is not necessarily its next adjacent cell.
    ///
    /// - returns: `true` if `cell` has a succeeding `FocusableCell` in the form. `false`
    ///            otherwise.
    func focusableCellHasSuccessor(_ cell: FocusableCell) -> Bool

    /// `cell` attempts to yield its focus.
    ///
    /// - returns: `true` if the focus has been yielded to a succeeding `FocusableCell`.
    ///            `false` if there is no `FocusableCell` succeeding `cell`.
    func focusableCellShouldYieldFocus(_ cell: FocusableCell) -> Bool
}

public protocol FocusableCell: class {
    var delegate: FocusableCellDelegate? { get set }

    func focus()
}

protocol FocusableFormComponent {
    var isPreferredForFocusing: Bool { get }
}

extension FocusableFormComponent {
    public var isPreferredForFocusing: Bool {
        return false
    }
}

protocol Selectable {
	var isSelected: Action<Void, Void, NoError> { get }
}
