public enum ScreenLifecycleEvent: Equatable {
    /// The screen has been loaded, but is not yet part of a view hierarchy.
    case didLoad

    /// The screen is about to appear because its parent intends to insert it into its view hierarchy.
    ///
    /// - isPresentedInitially: Whether this is the first time the parent has presented this screen. This would be
    ///                         `false` when, for example, a screen in a navigation flow is about to appear again
    ///                         because the user pops back to it.
    case willAppear(isPresentedInitially: Bool)

    /// The screen has been added to the view hierarchy. This need not happen at the exact moment the addition had
    /// happened — it could be triggered at the end of an animated transition, for example.
    ///
    /// - isPresentedInitially: Whether this is the first time the parent has presented this screen. This would be
    ///                         `false` when, for example, a screen in a navigation flow has appeared again because the
    ///                         user pops back to it.
    case didAppear(isPresentedInitially: Bool)

    /// The screen is about to disappear because its parent intends to remove it from its view hierarchy.
    ///
    /// - isRemovedPermanently: Whether the parent intends to remove this screen permanently from its arrangement. This
    ///                         would be `false` when, for example, a screen in a navigation flow is about to be hidden
    ///                         because another screen is pushed.
    case willDisappear(isRemovedPermanently: Bool)

    /// The screen has been removed from a view hierarchy. This need not happen at the exact moment the removal had
    /// happened — it could be triggered at the end of an animated transition, for example.
    ///
    /// - isRemovedPermanently: Whether the parent has removed this screen permanently from its arrangement. This
    ///                         would be `false` when, for example, a screen in a navigation flow has been hidden
    ///                         because another screen is pushed.
    case didDisappear(isRemovedPermanently: Bool)
}
