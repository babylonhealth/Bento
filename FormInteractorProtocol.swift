import ReactiveSwift
import enum Result.NoError

public protocol DynamicHeightCellDelegate: class {
    /// Inform that the cell content height has changed due to user interaction.
    ///
    /// - warning: You **MUST** not call this during normal layout passes.
    func dynamicHeightCellHeightDidChange(delta: CGFloat)
}

public protocol DynamicHeightCell: class {
    var heightDelegate: DynamicHeightCellDelegate? { get set }
}

public protocol FocusableCellDelegate: class {
    /// Whether `cell` has a succeeding `FocusableCell`.
    ///
    /// - note:  The cell is not necessarily its next adjacent cell.
    ///
    /// - returns: `true` if `cell` has a succeeding `FocusableCell` in the form. `false`
    ///            otherwise.
    func focusableCellHasSuccessor(_ cell: FocusableCell) -> Bool

    /// `cell` is about to yield its (subview's) first responder status.
    ///
    /// - returns: `true` if `cell` should proceed on resigning the status. `false` if
    ///            the delegate takes control of the resigning process.
    func focusableCellWillResignFirstResponder(_ cell: FocusableCell) -> Bool
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

protocol DeletableCell {
    var canBeDeleted: Bool { get }

    func delete()
}

extension DeletableCell {
    public var canBeDeleted: Bool {
        return false
    }
}
