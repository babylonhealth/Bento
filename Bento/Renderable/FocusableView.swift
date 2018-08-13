/// Represent the root view of a `Focusable` component.
@objc(BentoFocusableView)
public protocol FocusableView: AnyObject {
    /// Assume focus.
    ///
    /// Root views of `Focusable` components must implement this method to
    /// respond to the focus request from the focus coordination.
    @objc(bento_focus)
    func focus()

    /// Signify the focus eligibility of neighboring components might have
    /// changed.
    ///
    /// If you implement controls that depend on focus eligibility status* of
    /// neighboring components e.g. return key, and back/forward buttons as
    /// input accessories, you should implement this method to be notified when
    /// these statuses might have changed and invalidated the state of your
    /// controls.
    ///
    /// \* queried via `FocusCoordinating.canMove(_:)`.
    @objc(bento_neighboringFocusEligibilityDidChange)
    optional func neighboringFocusEligibilityDidChange()
}

extension FocusableView where Self: UIView {
    /// The focus coordinator of this view.
    ///
    /// - warning: The focus coordinator should not escape the closure scope.
    ///            The behavior is undefined if you retain the coordinator.
    public func withFocusCoordinator<Result>(_ action: (FocusCoordinating) -> Result) -> Result {
        let coordinator = search(from: self, type: FocusCoordinatorProviding.self)?
            .focusCoordinator(for: self)
            ?? DefaultFocusCoordinator()
        return action(coordinator)
    }
}

internal protocol FocusCoordinatorProviding: AnyObject {
    func focusCoordinator(for view: UIView) -> FocusCoordinating?
}
